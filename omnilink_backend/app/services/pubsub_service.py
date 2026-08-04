import asyncio
import json
import uuid
from datetime import datetime, timezone
from typing import Dict, Set

from app.cache.redis_client import get_redis_pool

# Map of user_id to a set of their active asyncio.Queues
_user_queues: Dict[uuid.UUID, Set[asyncio.Queue]] = {}
_listener_task: asyncio.Task | None = None

def _user_inbox_channel(user_id: uuid.UUID) -> str:
    return f"user:{user_id}:inbox"


async def publish_to_user_channel(user_id: uuid.UUID, envelope: dict) -> None:
    redis_pool = get_redis_pool()
    envelope["timestamp"] = datetime.now(timezone.utc).isoformat()
    await redis_pool.publish(_user_inbox_channel(user_id), json.dumps(envelope))


async def subscribe_user(user_id: uuid.UUID) -> asyncio.Queue:
    if user_id not in _user_queues:
        _user_queues[user_id] = set()
    
    queue = asyncio.Queue()
    _user_queues[user_id].add(queue)
    return queue


def unsubscribe_user(user_id: uuid.UUID, queue: asyncio.Queue) -> None:
    if user_id in _user_queues:
        _user_queues[user_id].discard(queue)
        if not _user_queues[user_id]:
            del _user_queues[user_id]


async def _redis_listener_loop():
    redis_pool = get_redis_pool()
    pubsub = redis_pool.pubsub()
    await pubsub.psubscribe("user:*:inbox")
    
    try:
        async for message in pubsub.listen():
            if message["type"] == "pmessage":
                channel = message["channel"]
                data = message["data"]
                
                # Extract user_id from channel: user:<uuid>:inbox
                parts = channel.split(":")
                if len(parts) == 3:
                    try:
                        user_id = uuid.UUID(parts[1])
                        # Fan out to all queues for this user
                        if user_id in _user_queues:
                            for queue in _user_queues[user_id]:
                                queue.put_nowait(data)
                    except ValueError:
                        pass
    except asyncio.CancelledError:
        pass
    finally:
        try:
            await pubsub.punsubscribe("user:*:inbox")
            await pubsub.close()
        except Exception:
            pass


def get_active_sse_stats() -> dict:
    """Return real-time SSE multiplexer stats from in-memory state."""
    total_streams = sum(len(queues) for queues in _user_queues.values())
    return {
        "active_users": len(_user_queues),      # unique users with open streams
        "total_streams": total_streams,          # total SSE connections (users × devices)
    }


def start_multiplexer():
    global _listener_task
    if _listener_task is None:
        _listener_task = asyncio.create_task(_redis_listener_loop())


async def stop_multiplexer():
    global _listener_task
    if _listener_task is not None:
        _listener_task.cancel()
        try:
            await _listener_task
        except asyncio.CancelledError:
            pass
        _listener_task = None
