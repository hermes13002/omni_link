import json
import uuid
from datetime import datetime, timezone

from app.cache.redis_client import get_redis_pool


def _user_inbox_channel(user_id: uuid.UUID) -> str:
    return f"user:{user_id}:inbox"


async def publish_to_user_channel(user_id: uuid.UUID, envelope: dict) -> None:
    redis_pool = get_redis_pool()
    envelope["timestamp"] = datetime.now(timezone.utc).isoformat()
    await redis_pool.publish(_user_inbox_channel(user_id), json.dumps(envelope))


async def open_user_channel_subscription(user_id: uuid.UUID):
    redis_pool = get_redis_pool()
    pubsub = redis_pool.pubsub()
    channel = _user_inbox_channel(user_id)
    await pubsub.subscribe(channel)
    return pubsub, channel
