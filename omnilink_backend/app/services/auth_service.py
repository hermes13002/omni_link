import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import conflict_exception, credentials_exception
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from app.db.models.user import User
from app.schemas.auth import RegisterRequest, TokenResponse


async def register_user(payload: RegisterRequest, db: AsyncSession) -> User:
    existing = await db.scalar(select(User).where(User.email == payload.email))
    if existing is not None:
        raise conflict_exception
    user = User(
        email=payload.email,
        hashed_password=hash_password(payload.password),
        display_name=payload.display_name,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


async def authenticate_user(email: str, password: str, db: AsyncSession) -> User:
    user = await db.scalar(select(User).where(User.email == email))
    if user is None or not verify_password(password, user.hashed_password):
        raise credentials_exception
    return user


def build_token_response(user_id: uuid.UUID) -> TokenResponse:
    subject = str(user_id)
    return TokenResponse(
        access_token=create_access_token(subject),
        refresh_token=create_refresh_token(subject),
    )


async def refresh_tokens(refresh_token: str, db: AsyncSession) -> TokenResponse:
    payload = decode_token(refresh_token)
    if not payload or payload.get("type") != "refresh":
        raise credentials_exception
    raw_user_id = payload.get("sub")
    if not raw_user_id:
        raise credentials_exception
    user = await db.get(User, uuid.UUID(raw_user_id))
    if user is None:
        raise credentials_exception
    return build_token_response(user.id)
