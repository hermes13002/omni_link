import re
import uuid
import mimetypes
from urllib.parse import urlparse

import httpx
from fastapi import BackgroundTasks, UploadFile
from sqlalchemy import func, select, or_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.exceptions import forbidden_exception, not_found_exception
from app.db.base import async_session_factory
from app.db.models.card import Card, CardType
from app.db.models.tag import Tag
from app.schemas.card import (
    CardListResponse,
    CardPatch,
    CardResponse,
    MetadataCardCreate,
    TextCardCreate,
)
from app.storage.gcs_client import delete_object, generate_signed_url, upload_file_stream
from app.services.pubsub_service import publish_to_user_channel
import socket
import ipaddress


def _is_valid_url(text: str) -> bool:
    try:
        parsed = urlparse(text.strip())
        return parsed.scheme in ("http", "https") and bool(parsed.netloc)
    except Exception:
        return False


def _extract_meta_content(html: str, prop: str) -> str | None:
    if prop == "title":
        match = re.search(r"<title[^>]*>([^<]{1,300})</title>", html, re.IGNORECASE)
        return match.group(1).strip() if match else None

    attribute_first = (
        rf'<meta[^>]+(?:property|name)\s*=\s*["\']?{re.escape(prop)}["\']?'
        rf'[^>]+content\s*=\s*["\']([^"\']+)["\']'
    )
    content_first = (
        rf'<meta[^>]+content\s*=\s*["\']([^"\']+)["\']'
        rf'[^>]+(?:property|name)\s*=\s*["\']?{re.escape(prop)}["\']?'
    )
    for pattern in (attribute_first, content_first):
        match = re.search(pattern, html, re.IGNORECASE)
        if match:
            return match.group(1).strip()
    return None


def is_safe_url(url: str) -> bool:
    try:
        parsed = urlparse(url)
        hostname = parsed.hostname
        if not hostname:
            return False
        ip = socket.gethostbyname(hostname)
        ip_obj = ipaddress.ip_address(ip)
        return ip_obj.is_global and not ip_obj.is_loopback and not ip_obj.is_link_local
    except socket.error:
        return False
    except ValueError:
        return False

async def _fetch_og_metadata(url: str) -> tuple[str | None, str | None]:
    if not is_safe_url(url):
        return None, None
    try:
        async with httpx.AsyncClient(
            timeout=8.0, follow_redirects=True
        ) as client:
            response = await client.get(
                url, headers={"User-Agent": "OmniLink/1.0"}
            )
            response.raise_for_status()
            html = response.text
        og_title = _extract_meta_content(html, "og:title") or _extract_meta_content(
            html, "title"
        )
        og_image = _extract_meta_content(html, "og:image")
        return og_title, og_image
    except Exception:
        return None, None


async def _resolve_tags(
    tag_ids: list[int],
    user_id: uuid.UUID,
    db: AsyncSession,
) -> list[Tag]:
    if not tag_ids:
        result = await db.scalars(
            select(Tag).where(func.lower(Tag.name) == 'general', Tag.user_id == user_id)
        )
        general_tag = result.first()
        if not general_tag:
            general_tag = Tag(name="General", user_id=user_id, color_hex="#808080")
            db.add(general_tag)
            await db.flush()
        return [general_tag]

    result = await db.scalars(
        select(Tag).where(Tag.id.in_(tag_ids), Tag.user_id == user_id)
    )
    return list(result.all())


async def _build_card_response(card: Card) -> CardResponse:
    signed_url: str | None = None
    if card.card_type == CardType.file and card.gcs_object_key:
        signed_url = await generate_signed_url(card.gcs_object_key)
    return CardResponse(
        id=card.id,
        card_type=card.card_type,
        title=card.title,
        body=card.body,
        pinned=card.pinned,
        tags=card.tags,
        gcs_signed_url=signed_url,
        mime_type=card.mime_type,
        file_size_bytes=card.file_size_bytes,
        og_title=card.og_title,
        og_image=card.og_image,
        source_device_id=card.source_device_id,
        created_at=card.created_at,
        updated_at=card.updated_at,
    )


async def _backfill_url_metadata(card_id: uuid.UUID, url: str) -> None:
    og_title, og_image = await _fetch_og_metadata(url)
    async with async_session_factory() as db:
        card = await db.get(Card, card_id)
        if card is not None:
            card.og_title = og_title
            card.og_image = og_image
            await db.commit()


async def create_text_card(
    payload: TextCardCreate,
    user_id: uuid.UUID,
    db: AsyncSession,
    background_tasks: BackgroundTasks,
) -> CardResponse:
    tags = await _resolve_tags(payload.tag_ids, user_id, db)
    card = Card(
        user_id=user_id,
        source_device_id=payload.source_device_id,
        card_type=CardType.text,
        title=payload.title,
        body=payload.body,
        tags=tags,
    )
    db.add(card)
    await db.commit()
    await db.refresh(card, ["tags"])

    if payload.body and _is_valid_url(payload.body):
        background_tasks.add_task(_backfill_url_metadata, card.id, payload.body)

    await publish_to_user_channel(user_id, {"event": "card_created", "card_id": str(card.id)})
    return await _build_card_response(card)


async def create_metadata_card(
    payload: MetadataCardCreate,
    user_id: uuid.UUID,
    db: AsyncSession,
) -> CardResponse:
    tags = await _resolve_tags(payload.tag_ids, user_id, db)
    card = Card(
        user_id=user_id,
        source_device_id=payload.source_device_id,
        card_type=CardType.metadata,
        title=payload.title,
        body=payload.body,
        tags=tags,
    )
    db.add(card)
    await db.commit()
    await db.refresh(card, ["tags"])
    await publish_to_user_channel(user_id, {"event": "card_created", "card_id": str(card.id)})
    return await _build_card_response(card)


async def create_file_card(
    file: UploadFile,
    tag_ids: list[int],
    source_device_id: uuid.UUID | None,
    user_id: uuid.UUID,
    db: AsyncSession,
) -> CardResponse:
    object_key = f"cards/{user_id}/{uuid.uuid4()}/{file.filename}"
    content_type = file.content_type
    if not content_type or content_type == "application/octet-stream":
        guessed, _ = mimetypes.guess_type(file.filename)
        content_type = guessed or "application/octet-stream"
        
    await upload_file_stream(object_key, file.file, content_type)

    tags = await _resolve_tags(tag_ids, user_id, db)
    card = Card(
        user_id=user_id,
        source_device_id=source_device_id,
        card_type=CardType.file,
        title=file.filename,
        gcs_object_key=object_key,
        mime_type=content_type,
        file_size_bytes=file.size or 0,
        tags=tags,
    )
    db.add(card)
    await db.commit()
    await db.refresh(card, ["tags"])
    await publish_to_user_channel(user_id, {"event": "card_created", "card_id": str(card.id)})
    return await _build_card_response(card)


async def list_cards(
    user_id: uuid.UUID,
    db: AsyncSession,
    card_type: CardType | None = None,
    tag_id: int | None = None,
    pinned: bool | None = None,
    search: str | None = None,
    page: int = 1,
    page_size: int = 20,
) -> CardListResponse:
    base_filters = [Card.user_id == user_id]
    if card_type is not None:
        base_filters.append(Card.card_type == card_type)
    if pinned is not None:
        base_filters.append(Card.pinned == pinned)
    if tag_id is not None:
        base_filters.append(Card.tags.any(Tag.id == tag_id))
    if search is not None and search.strip():
        search_term = f"%{search.strip()}%"
        base_filters.append(
            or_(
                Card.title.ilike(search_term),
                Card.body.ilike(search_term),
                Card.og_title.ilike(search_term),
                Card.gcs_object_key.ilike(search_term),
            )
        )

    total = await db.scalar(select(func.count(Card.id)).where(*base_filters)) or 0

    result = await db.scalars(
        select(Card)
        .where(*base_filters)
        .options(selectinload(Card.tags))
        .order_by(Card.created_at.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    )
    cards = result.all()

    items = [await _build_card_response(c) for c in cards]
    return CardListResponse(items=items, total=total, page=page, page_size=page_size)


async def get_card(
    card_id: uuid.UUID,
    user_id: uuid.UUID,
    db: AsyncSession,
) -> CardResponse:
    card = await db.scalar(
        select(Card)
        .where(Card.id == card_id)
        .options(selectinload(Card.tags))
    )
    if card is None:
        raise not_found_exception
    if card.user_id != user_id:
        raise forbidden_exception
    return await _build_card_response(card)


async def patch_card(
    card_id: uuid.UUID,
    payload: CardPatch,
    user_id: uuid.UUID,
    db: AsyncSession,
) -> CardResponse:
    card = await db.scalar(
        select(Card)
        .where(Card.id == card_id)
        .options(selectinload(Card.tags))
    )
    if card is None:
        raise not_found_exception
    if card.user_id != user_id:
        raise forbidden_exception

    if payload.title is not None:
        card.title = payload.title
    if payload.body is not None:
        card.body = payload.body
    if payload.pinned is not None:
        card.pinned = payload.pinned
    if payload.tag_ids is not None:
        card.tags = await _resolve_tags(payload.tag_ids, user_id, db)

    await db.commit()
    await db.refresh(card, ["tags"])
    await publish_to_user_channel(user_id, {"event": "card_updated", "card_id": str(card.id)})
    return await _build_card_response(card)


async def delete_card(
    card_id: uuid.UUID,
    user_id: uuid.UUID,
    db: AsyncSession,
) -> None:
    card = await db.get(Card, card_id)
    if card is None:
        raise not_found_exception
    if card.user_id != user_id:
        raise forbidden_exception
    if card.card_type == CardType.file and card.gcs_object_key:
        await delete_object(card.gcs_object_key)
    await db.delete(card)
    await db.commit()
    await publish_to_user_channel(user_id, {"event": "card_deleted", "card_id": str(card_id)})
