import uuid
from collections.abc import AsyncGenerator

from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import credentials_exception
from app.core.security import decode_token
from app.db.base import get_async_session
from app.db.models.user import User
from app.cache.redis_client import get_redis_pool
import hashlib

_bearer_scheme = HTTPBearer()


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async for session in get_async_session():
        yield session


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(_bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    # Check if access token is blocklisted
    redis_client = get_redis_pool()
    hashed_at = hashlib.sha256(credentials.credentials.encode()).hexdigest()
    is_blacklisted = await redis_client.get(f"bl_{hashed_at}")
    if is_blacklisted:
        raise credentials_exception

    token_data = decode_token(credentials.credentials)
    if not token_data or token_data.get("type") != "access":
        raise credentials_exception
    raw_user_id = token_data.get("sub")
    if not raw_user_id:
        raise credentials_exception
    user = await db.get(User, uuid.UUID(raw_user_id))
    if user is None:
        raise credentials_exception
    if user.is_suspended:
        raise credentials_exception
    return user
