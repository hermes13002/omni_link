"""add compound index on cards user_id updated_at

Revision ID: abcdef123456
Revises: def456abc123
Create Date: 2026-08-28 02:59:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = 'abcdef123456'
down_revision: Union[str, None] = 'def456abc123'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_index(
        'ix_cards_user_id_updated_at', 
        'cards', 
        ['user_id', 'updated_at'], 
        unique=False
    )


def downgrade() -> None:
    op.drop_index('ix_cards_user_id_updated_at', table_name='cards')
