import uuid
from typing import Any

from fastapi import APIRouter, Depends, status
from pydantic import BaseModel

from app.core.identifiers import PrefixedDeviceId

from app.api.deps import get_current_user
from app.db.models.user import User
from app.schemas.response import ApiResponse
from app.services.pubsub_service import publish_to_user_channel

router = APIRouter(prefix="/push", tags=["push"])


class PushRequest(BaseModel):
    payload: Any
    target_device_ids: list[PrefixedDeviceId] | None = None


class PushAck(BaseModel):
    status: str = "published"


@router.post("", status_code=status.HTTP_202_ACCEPTED, response_model=ApiResponse[PushAck])
async def push(
    body: PushRequest,
    current_user: User = Depends(get_current_user),
) -> ApiResponse[PushAck]:
    envelope = {
        "payload": body.payload,
        "target_device_ids": (
            [str(d) for d in body.target_device_ids]
            if body.target_device_ids
            else None
        ),
    }
    await publish_to_user_channel(current_user.id, envelope)
    return ApiResponse(data=PushAck())
