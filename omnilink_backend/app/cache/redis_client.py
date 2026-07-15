import redis.asyncio as aioredis

from app.config import settings

_redis_pool: aioredis.Redis | None = None


async def init_redis_pool() -> aioredis.Redis:
    global _redis_pool
    _redis_pool = aioredis.from_url(
        settings.redis_url,
        encoding="utf-8",
        decode_responses=True,
        max_connections=50,
    )
    return _redis_pool


async def close_redis_pool() -> None:
    global _redis_pool
    if _redis_pool is not None:
        await _redis_pool.aclose()
        _redis_pool = None


def get_redis_pool() -> aioredis.Redis:
    if _redis_pool is None:
        raise RuntimeError("redis pool is not initialized")
    return _redis_pool
