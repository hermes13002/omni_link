import uuid
from datetime import datetime

from pydantic import BaseModel

from app.core.identifiers import PrefixedDeviceId


class DeviceRegisterRequest(BaseModel):
    client_uuid: str
    friendly_name: str


class DeviceResponse(BaseModel):
    id: PrefixedDeviceId
    client_uuid: str
    friendly_name: str
    last_seen: datetime | None
    created_at: datetime

    model_config = {"from_attributes": True}


class DeviceRegisterResponse(DeviceResponse):
    device_secret: str
