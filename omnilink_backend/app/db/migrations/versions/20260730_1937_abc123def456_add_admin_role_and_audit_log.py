"""add admin role and audit log

Revision ID: abc123def456
Revises: 43e68c31e12e
Create Date: 2026-07-30 19:37:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = 'abc123def456'
down_revision: Union[str, None] = '43e68c31e12e'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # 1. Create the userrole enum type
    op.execute("CREATE TYPE userrole AS ENUM ('USER', 'ADMIN')")

    # 2. Add columns to users table
    op.execute("ALTER TABLE users ADD COLUMN role userrole NOT NULL DEFAULT 'USER'")
    op.execute("ALTER TABLE users ADD COLUMN is_suspended BOOLEAN NOT NULL DEFAULT false")

    # 3. Create admin_audit_logs table
    op.create_table('admin_audit_logs',
    sa.Column('id', postgresql.UUID(as_uuid=True), nullable=False),
    sa.Column('admin_id', postgresql.UUID(as_uuid=True), nullable=True),
    sa.Column('action', sa.String(length=255), nullable=False),
    sa.Column('resource_type', sa.String(length=100), nullable=False),
    sa.Column('resource_id', sa.String(length=255), nullable=True),
    sa.Column('details', sa.JSON(), nullable=True),
    sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
    sa.ForeignKeyConstraint(['admin_id'], ['users.id'], ondelete='SET NULL'),
    sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_admin_audit_logs_admin_id'), 'admin_audit_logs', ['admin_id'], unique=False)


def downgrade() -> None:
    op.drop_index(op.f('ix_admin_audit_logs_admin_id'), table_name='admin_audit_logs')
    op.drop_table('admin_audit_logs')
    op.drop_column('users', 'is_suspended')
    op.drop_column('users', 'role')
    userrole_enum = postgresql.ENUM('USER', 'ADMIN', name='userrole')
    userrole_enum.drop(op.get_bind())
