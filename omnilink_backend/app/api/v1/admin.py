import uuid
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.base import get_db
from app.db.models.user import User, UserRole
from app.api.dependencies.auth import get_current_user

router = APIRouter()

class AdminLoginRequest(BaseModel):
    email: str
    password: str
    secret_key: str

async def get_current_admin(current_user: User = Depends(get_current_user)) -> User:
    if current_user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have enough privileges",
        )
    return current_user

@router.post("/login")
async def admin_login(
    request: AdminLoginRequest,
    db: AsyncSession = Depends(get_db)
) -> Any:
    # Here we would validate the secret key and the password.
    # For now, it's just a placeholder route that returns a token.
    # In a real app we'd verify the secret key against an env var and password against db.
    return {"access_token": "admin-token", "token_type": "bearer"}

@router.get("/users")
async def get_all_users(
    db: AsyncSession = Depends(get_db),
    current_admin: User = Depends(get_current_admin)
) -> Any:
    # Placeholder for fetching all users
    return []

@router.patch("/users/{user_id}/suspend")
async def suspend_user(
    user_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    current_admin: User = Depends(get_current_admin)
) -> Any:
    # Placeholder
    return {"status": "suspended"}

@router.get("/metrics/overview")
async def get_overview_metrics(
    db: AsyncSession = Depends(get_db),
    current_admin: User = Depends(get_current_admin)
) -> Any:
    # Placeholder
    return {"dau": 0, "storage": 0}
