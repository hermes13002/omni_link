import uuid
from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import conflict_exception, forbidden_exception, not_found_exception
from app.core.security import generate_device_secret, hash_device_secret
from app.db.models.device import Device
from app.schemas.device import DeviceRegisterRequest, DeviceRegisterResponse, DeviceResponse, DevicePatch


async def register_device(
    payload: DeviceRegisterRequest,
    user_id: uuid.UUID,
    db: AsyncSession,
) -> DeviceRegisterResponse:
    existing = await db.scalar(
        select(Device).where(Device.client_uuid == payload.client_uuid)
    )
    if existing is not None:
        raise conflict_exception

    plain_secret, hashed_secret = generate_device_secret()
    device = Device(
        user_id=user_id,
        client_uuid=payload.client_uuid,
        friendly_name=payload.friendly_name,
        hashed_device_secret=hashed_secret,
    )
    db.add(device)
    await db.commit()
    await db.refresh(device)

    return DeviceRegisterResponse(
        id=device.id,
        client_uuid=device.client_uuid,
        friendly_name=device.friendly_name,
        last_seen=device.last_seen,
        created_at=device.created_at,
        device_secret=plain_secret,
    )


async def list_user_devices(user_id: uuid.UUID, db: AsyncSession) -> list[DeviceResponse]:
    result = await db.scalars(select(Device).where(Device.user_id == user_id))
    return [DeviceResponse.model_validate(d) for d in result.all()]


async def delete_device(
    device_id: uuid.UUID,
    user_id: uuid.UUID,
    db: AsyncSession,
) -> None:
    device = await db.get(Device, device_id)
    if device is None:
        raise not_found_exception
    if device.user_id != user_id:
        raise forbidden_exception
    await db.delete(device)
    await db.commit()


async def update_device(
    device_id: uuid.UUID,
    payload: DevicePatch,
    user_id: uuid.UUID,
    db: AsyncSession,
) -> DeviceResponse:
    device = await db.get(Device, device_id)
    if device is None:
        raise not_found_exception
    if device.user_id != user_id:
        raise forbidden_exception
    device.friendly_name = payload.friendly_name
    await db.commit()
    return DeviceResponse.model_validate(device)


async def get_device_by_plain_secret(
    plain_secret: str,
    db: AsyncSession,
) -> Device | None:
    hashed = hash_device_secret(plain_secret)
    return await db.scalar(
        select(Device).where(Device.hashed_device_secret == hashed)
    )


async def touch_device_last_seen(device: Device, db: AsyncSession) -> None:
    device.last_seen = datetime.now(timezone.utc)
    await db.commit()
