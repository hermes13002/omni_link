from sqlalchemy import Column, ForeignKey, Integer, Table
from sqlalchemy.dialects.postgresql import UUID as PgUUID

from app.db.base import Base

card_tags = Table(
    "card_tags",
    Base.metadata,
    Column(
        "card_id",
        PgUUID(as_uuid=True),
        ForeignKey("cards.id", ondelete="CASCADE"),
        primary_key=True,
    ),
    Column(
        "tag_id",
        Integer,
        ForeignKey("tags.id", ondelete="CASCADE"),
        primary_key=True,
    ),
)
