import uuid
from datetime import datetime

import nh3
from pydantic import BaseModel, field_validator

from app.core.identifiers import PrefixedCardId, PrefixedTagId, PrefixedDeviceId
from app.db.models.card import CardType


class TagSummary(BaseModel):
    id: PrefixedTagId
    name: str
    color_hex: str | None

    model_config = {"from_attributes": True}


class TextCardCreate(BaseModel):
    title: str | None = None
    body: str
    tag_ids: list[PrefixedTagId] = []
    source_device_id: PrefixedDeviceId | None = None
    
    @field_validator('title', 'body', mode='before')
    @classmethod
    def sanitize_html(cls, v: str | None) -> str | None:
        if isinstance(v, str):
            return nh3.clean(v)
        return v


class MetadataCardCreate(BaseModel):
    title: str
    body: str | None = None
    tag_ids: list[PrefixedTagId] = []
    source_device_id: PrefixedDeviceId | None = None
    
    @field_validator('title', 'body', mode='before')
    @classmethod
    def sanitize_html(cls, v: str | None) -> str | None:
        if isinstance(v, str):
            return nh3.clean(v)
        return v


class CardPatch(BaseModel):
    title: str | None = None
    body: str | None = None
    pinned: bool | None = None
    tag_ids: list[PrefixedTagId] | None = None
    
    @field_validator('title', 'body', mode='before')
    @classmethod
    def sanitize_html(cls, v: str | None) -> str | None:
        if isinstance(v, str):
            return nh3.clean(v)
        return v


class CardResponse(BaseModel):
    id: PrefixedCardId
    card_type: CardType
    title: str | None
    body: str | None
    pinned: bool
    tags: list[TagSummary]
    gcs_signed_url: str | None = None
    mime_type: str | None
    file_size_bytes: int | None
    og_title: str | None
    og_image: str | None
    source_device_id: PrefixedDeviceId | None
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class CardListResponse(BaseModel):
    items: list[CardResponse]
    total: int
    page: int
    page_size: int
