import enum
import uuid
from datetime import datetime, timezone

from sqlalchemy import BigInteger, Boolean, DateTime, Enum as SAEnum, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID as PgUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.db.models.associations import card_tags
from app.db.encrypted_type import EncryptedText


class CardType(str, enum.Enum):
    text = "text"
    metadata = "metadata"
    file = "file"


class Card(Base):
    __tablename__ = "cards"

    id: Mapped[uuid.UUID] = mapped_column(
        PgUUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    source_device_id: Mapped[uuid.UUID | None] = mapped_column(
        PgUUID(as_uuid=True),
        ForeignKey("devices.id", ondelete="SET NULL"),
    )
    card_type: Mapped[CardType] = mapped_column(
        SAEnum(CardType, name="cardtype"), nullable=False
    )
    title: Mapped[str | None] = mapped_column(EncryptedText)
    body: Mapped[str | None] = mapped_column(EncryptedText)
    gcs_object_key: Mapped[str | None] = mapped_column(Text)
    mime_type: Mapped[str | None] = mapped_column(Text)
    file_size_bytes: Mapped[int | None] = mapped_column(BigInteger)
    pinned: Mapped[bool] = mapped_column(Boolean, default=False)
    og_title: Mapped[str | None] = mapped_column(Text)
    og_image: Mapped[str | None] = mapped_column(Text)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    user: Mapped["User"] = relationship(back_populates="cards")
    source_device: Mapped["Device | None"] = relationship(back_populates="source_cards")
    tags: Mapped[list["Tag"]] = relationship(secondary=card_tags, back_populates="cards")
