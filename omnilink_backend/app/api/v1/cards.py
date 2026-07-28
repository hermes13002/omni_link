import uuid

from fastapi import APIRouter, BackgroundTasks, Depends, Query, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db
from app.core.identifiers import PrefixedCardId, PrefixedTagId, PrefixedDeviceId, base62_decode
from app.db.models.card import CardType
from app.db.models.user import User
from app.schemas.card import (
    CardListResponse,
    CardPatch,
    CardResponse,
    MetadataCardCreate,
    TextCardCreate,
)
from app.schemas.response import ApiResponse
from app.services import card_service

router = APIRouter(prefix="/cards", tags=["cards"])


@router.get("", response_model=ApiResponse[CardListResponse])
async def list_cards(
    card_type: CardType | None = Query(None),
    tag_id: PrefixedTagId | None = Query(None),
    pinned: bool | None = Query(None),
    search: str | None = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[CardListResponse]:
    return ApiResponse(data=await card_service.list_cards(
        current_user.id, db, card_type, tag_id, pinned, search, page, page_size
    ))


@router.post("/text", status_code=status.HTTP_201_CREATED, response_model=ApiResponse[CardResponse])
async def create_text_card(
    payload: TextCardCreate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[CardResponse]:
    return ApiResponse(data=await card_service.create_text_card(
        payload, current_user.id, db, background_tasks
    ))


@router.post("/metadata", status_code=status.HTTP_201_CREATED, response_model=ApiResponse[CardResponse])
async def create_metadata_card(
    payload: MetadataCardCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[CardResponse]:
    return ApiResponse(data=await card_service.create_metadata_card(payload, current_user.id, db))


@router.post("/file", status_code=status.HTTP_201_CREATED, response_model=ApiResponse[CardResponse])
async def create_file_card(
    file: UploadFile,
    tag_ids: str | None = Query(None, description="comma-separated prefixed tag IDs"),
    title: str | None = Query(None),
    source_device_id: PrefixedDeviceId | None = Query(None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[CardResponse]:
    parsed_tag_ids = (
        [base62_decode(t.strip().split("_")[-1]) for t in tag_ids.split(",") if t.strip()]
        if tag_ids
        else []
    )
    return ApiResponse(data=await card_service.create_file_card(
        file, parsed_tag_ids, title, source_device_id, current_user.id, db
    ))


@router.get("/{card_id}", response_model=ApiResponse[CardResponse])
async def get_card(
    card_id: PrefixedCardId,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[CardResponse]:
    return ApiResponse(data=await card_service.get_card(card_id, current_user.id, db))


@router.patch("/{card_id}", response_model=ApiResponse[CardResponse])
async def patch_card(
    card_id: PrefixedCardId,
    payload: CardPatch,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[CardResponse]:
    return ApiResponse(data=await card_service.patch_card(card_id, payload, current_user.id, db))


@router.delete("/{card_id}", response_model=ApiResponse[None])
async def delete_card(
    card_id: PrefixedCardId,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[None]:
    await card_service.delete_card(card_id, current_user.id, db)
    return ApiResponse(data=None)


@router.get("/{card_id}/download-url", response_model=ApiResponse[str])
async def get_card_download_url(
    card_id: PrefixedCardId,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[str]:
    url = await card_service.get_card_download_url(card_id, current_user.id, db)
    return ApiResponse(data=url)
