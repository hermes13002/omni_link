import uuid

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import forbidden_exception, not_found_exception
from app.db.models.tag import Tag
from app.schemas.tag import TagCreate, TagResponse


async def list_user_tags(user_id: uuid.UUID, db: AsyncSession) -> list[TagResponse]:
    result = await db.scalars(select(Tag).where(Tag.user_id == user_id))
    return [TagResponse.model_validate(t) for t in result.all()]


async def create_tag(
    payload: TagCreate,
    user_id: uuid.UUID,
    db: AsyncSession,
) -> TagResponse:
    tag = Tag(user_id=user_id, name=payload.name, color_hex=payload.color_hex)
    db.add(tag)
    await db.commit()
    await db.refresh(tag)
    return TagResponse.model_validate(tag)


async def delete_tag(tag_id: int, user_id: uuid.UUID, db: AsyncSession) -> None:
    tag = await db.get(Tag, tag_id)
    if tag is None:
        raise not_found_exception
    if tag.user_id != user_id:
        raise forbidden_exception
    await db.delete(tag)
    await db.commit()
