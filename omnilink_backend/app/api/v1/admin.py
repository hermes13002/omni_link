import uuid
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, distinct
from datetime import datetime, timezone, timedelta

from app.api.deps import get_db, get_current_user
from app.db.models.user import User, UserRole
from app.db.models.device import Device
from app.db.models.card import Card, CardType
from app.db.models.audit_log import AdminAuditLog
from app.services import auth_service
from app.config import settings
from app.schemas.auth import TokenResponse
from app.schemas.response import ApiResponse
from app.schemas.admin import AdminOverviewMetrics, AdminUserItem, AdminUsersResponse
from app.services.pubsub_service import get_active_sse_stats

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

@router.get("/users", response_model=ApiResponse[AdminUsersResponse])
async def get_all_users(
    db: AsyncSession = Depends(get_db),
    current_admin: User = Depends(get_current_admin)
) -> ApiResponse[AdminUsersResponse]:
    query = select(
        User,
        func.count(Device.id.distinct()).label("device_count"),
        func.sum(func.coalesce(Card.file_size_bytes, 0)).label("storage_used")
    ).outerjoin(Device, User.id == Device.user_id) \
     .outerjoin(Card, User.id == Card.user_id) \
     .group_by(User.id) \
     .order_by(User.created_at.desc())
     
    result = await db.execute(query)
    rows = result.all()
    
    users = []
    for user_obj, d_count, s_used in rows:
        users.append(AdminUserItem(
            id=user_obj.id,
            email=user_obj.email,
            display_name=user_obj.display_name,
            created_at=user_obj.created_at,
            role=user_obj.role.value if hasattr(user_obj.role, 'value') else str(user_obj.role),
            is_suspended=user_obj.is_suspended,
            device_count=d_count,
            storage_used_bytes=int(s_used or 0)
        ))
        
    return ApiResponse(data=AdminUsersResponse(users=users))

@router.patch("/users/{user_id}/suspend", response_model=ApiResponse[dict])
async def suspend_user(
    user_id: uuid.UUID,
    is_suspended: bool,
    db: AsyncSession = Depends(get_db),
    current_admin: User = Depends(get_current_admin)
) -> ApiResponse[dict]:
    user = await db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    user.is_suspended = is_suspended
    
    # Log the action
    action_str = "SUSPEND" if is_suspended else "RESTORE"
    audit_log = AdminAuditLog(
        admin_id=current_admin.id,
        action=action_str,
        resource_type="USER",
        resource_id=str(user_id)
    )
    db.add(audit_log)
    await db.commit()
    
    return ApiResponse(data={"status": action_str, "user_id": str(user_id)})

@router.get("/metrics/overview", response_model=ApiResponse[AdminOverviewMetrics])
async def get_overview_metrics(
    db: AsyncSession = Depends(get_db),
    current_admin: User = Depends(get_current_admin)
) -> ApiResponse[AdminOverviewMetrics]:
    # Total Users
    total_users = await db.scalar(select(func.count(User.id))) or 0
    total_devices = await db.scalar(select(func.count(Device.id))) or 0
    total_items = await db.scalar(select(func.count(Card.id))) or 0
    
    # New Users Today
    today_start = datetime.now(timezone.utc).replace(hour=0, minute=0, second=0, microsecond=0)
    new_users = await db.scalar(select(func.count(User.id)).where(User.created_at >= today_start)) or 0
    
    # Items by type
    cards_grouped = await db.execute(select(Card.card_type, func.count(Card.id)).group_by(Card.card_type))
    items_by_type = {}
    for c_type, count in cards_grouped.all():
        type_name = c_type.value if hasattr(c_type, 'value') else str(c_type)
        items_by_type[type_name] = count

    # Live SSE multiplexer stats
    sse_stats = get_active_sse_stats()

    return ApiResponse(data=AdminOverviewMetrics(
        sync_latency_ms=45.0, # Placeholder for APM
        active_sse_connections=sse_stats["total_streams"],
        db_pool_saturation_percent=12.5, # Placeholder for APM
        api_error_rate_percent=0.01, # Placeholder for APM
        daily_active_users=total_users, # Approximation (needs active session tracking ideally)
        devices_per_user=total_devices / total_users if total_users > 0 else 0.0,
        items_by_type=items_by_type,
        total_users=total_users,
        new_users_today=new_users,
        total_devices=total_devices,
        total_items=total_items
    ))
