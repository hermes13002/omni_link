from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_db
from app.core.identifiers import PrefixedTagId
from app.db.models.user import User
from app.schemas.response import ApiResponse
from app.schemas.tag import TagCreate, TagResponse
from app.services import tag_service

router = APIRouter(prefix="/tags", tags=["tags"])


@router.get("", response_model=ApiResponse[list[TagResponse]])
async def list_tags(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[list[TagResponse]]:
    return ApiResponse(data=await tag_service.list_user_tags(current_user.id, db))


@router.post("", status_code=status.HTTP_201_CREATED, response_model=ApiResponse[TagResponse])
async def create_tag(
    payload: TagCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[TagResponse]:
    return ApiResponse(data=await tag_service.create_tag(payload, current_user.id, db))


@router.delete("/{tag_id}", response_model=ApiResponse[None])
async def delete_tag(
    tag_id: PrefixedTagId,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ApiResponse[None]:
    await tag_service.delete_tag(tag_id, current_user.id, db)
    return ApiResponse(data=None)
