from fastapi import APIRouter, Depends, status, Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db, _bearer_scheme
from app.db.models.user import User
from app.schemas.auth import LoginRequest, RefreshRequest, RegisterRequest, TokenResponse, LogoutRequest, UpdateProfileRequest, ChangePasswordRequest
from app.schemas.response import ApiResponse
from app.schemas.user import UserResponse
from fastapi.security import HTTPAuthorizationCredentials
from app.services import auth_service
from app.core.rate_limit import limiter

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register", status_code=status.HTTP_201_CREATED, response_model=ApiResponse[TokenResponse])
@limiter.limit("5/minute")
async def register(
    request: Request,
    payload: RegisterRequest,
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[TokenResponse]:
    user = await auth_service.register_user(payload, db)
    return ApiResponse(data=auth_service.build_token_response(user.id))


@router.post("/login", response_model=ApiResponse[TokenResponse])
@limiter.limit("5/minute")
async def login(
    request: Request,
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


@router.post("/logout", response_model=ApiResponse[None])
async def logout(
    payload: LogoutRequest,
    credentials: HTTPAuthorizationCredentials = Depends(_bearer_scheme),
) -> ApiResponse[None]:
    await auth_service.logout_user(
        access_token=credentials.credentials,
        refresh_token=payload.refresh_token,
    )
    return ApiResponse(data=None)

@router.get("/me", response_model=ApiResponse[UserResponse])
async def get_me(
    current_user: User = Depends(get_current_user),
) -> ApiResponse[UserResponse]:
    return ApiResponse(data=current_user)

@router.patch("/me", response_model=ApiResponse[UserResponse])
async def update_profile(
    payload: UpdateProfileRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[UserResponse]:
    user = await auth_service.update_display_name(current_user.id, payload, db)
    return ApiResponse(data=user)

@router.patch("/password", response_model=ApiResponse[None])
async def update_password(
    payload: ChangePasswordRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[None]:
    await auth_service.change_password(current_user.id, payload, db)
    return ApiResponse(data=None)

@router.delete("/me", response_model=ApiResponse[None])
async def delete_me(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[None]:
    await auth_service.delete_account(current_user.id, db)
    return ApiResponse(data=None)
