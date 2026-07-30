import uuid
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.base import get_db
from app.db.models.user import User, UserRole
from app.api.deps import get_current_user
from app.services import auth_service
from app.config import settings
from app.schemas.auth import TokenResponse
from app.schemas.response import ApiResponse

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

@router.post("/login", response_model=ApiResponse[TokenResponse])
async def admin_login(
    request: AdminLoginRequest,
    db: AsyncSession = Depends(get_db)
) -> ApiResponse[TokenResponse]:
    # 1. Verify the secret key
    if request.secret_key != settings.admin_secret_key:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid secret key",
        )
    
    # 2. Authenticate the user (checks email and password)
    user = await auth_service.authenticate_user(request.email, request.password, db)
    
    # 3. Ensure the user is an admin
    if user.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have administrative privileges",
        )
        
    # 4. Generate token response
    return ApiResponse(data=auth_service.build_token_response(user.id))

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
