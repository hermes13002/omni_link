from datetime import datetime

from pydantic import BaseModel, EmailStr

from app.core.identifiers import PrefixedUserId


class UserResponse(BaseModel):
    id: PrefixedUserId
    email: EmailStr
    display_name: str | None
    created_at: datetime

    model_config = {"from_attributes": True}
