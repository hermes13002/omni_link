from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db
from app.db.models.user import User
from app.schemas.auth import LoginRequest, RefreshRequest, RegisterRequest, TokenResponse
from app.schemas.response import ApiResponse
from app.schemas.user import UserResponse
from app.services import auth_service

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", status_code=status.HTTP_201_CREATED, response_model=ApiResponse[TokenResponse])
async def register(
    payload: RegisterRequest,
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[TokenResponse]:
    user = await auth_service.register_user(payload, db)
    return ApiResponse(data=auth_service.build_token_response(user.id))


@router.post("/login", response_model=ApiResponse[TokenResponse])
async def login(
    payload: LoginRequest,
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[TokenResponse]:
    user = await auth_service.authenticate_user(payload.email, payload.password, db)
    return ApiResponse(data=auth_service.build_token_response(user.id))


@router.post("/refresh", response_model=ApiResponse[TokenResponse])
async def refresh(
    payload: RefreshRequest,
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[TokenResponse]:
    return ApiResponse(data=await auth_service.refresh_tokens(payload.refresh_token, db))


@router.get("/me", response_model=ApiResponse[UserResponse])
async def get_me(
    current_user: User = Depends(get_current_user),
) -> ApiResponse[UserResponse]:
    return ApiResponse(data=current_user)
