from pydantic import BaseModel

from app.core.identifiers import PrefixedTagId


class TagCreate(BaseModel):
    name: str
    color_hex: str | None = None


class TagResponse(BaseModel):
    id: PrefixedTagId
    name: str
    color_hex: str | None

    model_config = {"from_attributes": True}
