import uuid

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db
from app.core.identifiers import PrefixedDeviceId
from app.db.models.user import User
from app.schemas.device import DeviceRegisterRequest, DeviceRegisterResponse, DeviceResponse
from app.schemas.response import ApiResponse
from app.services import device_service

router = APIRouter(prefix="/devices", tags=["devices"])


@router.post(
    "",
    status_code=status.HTTP_201_CREATED,
    response_model=ApiResponse[DeviceRegisterResponse],
)
async def register_device(
    payload: DeviceRegisterRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[DeviceRegisterResponse]:
    return ApiResponse(data=await device_service.register_device(payload, current_user.id, db))


@router.get("", response_model=ApiResponse[list[DeviceResponse]])
async def list_devices(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[list[DeviceResponse]]:
    return ApiResponse(data=await device_service.list_user_devices(current_user.id, db))


@router.delete("/{device_id}", response_model=ApiResponse[None])
async def delete_device(
    device_id: PrefixedDeviceId,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[None]:
    await device_service.delete_device(device_id, current_user.id, db)
    return ApiResponse(data=None)
