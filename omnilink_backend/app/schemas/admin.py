from pydantic import BaseModel
from typing import List, Dict, Any
import uuid
from datetime import datetime

class AdminOverviewMetrics(BaseModel):
    # Technical
    sync_latency_ms: float
    active_sse_connections: int
    db_pool_saturation_percent: float
    api_error_rate_percent: float
    
    # Product
    daily_active_users: int
    devices_per_user: float
    items_by_type: Dict[str, int]
    
    # Growth
    total_users: int
    new_users_today: int
    total_devices: int
    total_items: int

class AdminUserItem(BaseModel):
    id: uuid.UUID
    email: str
    display_name: str | None
    created_at: datetime
    role: str
    is_suspended: bool
    device_count: int
    storage_used_bytes: int

class AdminUsersResponse(BaseModel):
    users: List[AdminUserItem]

class AdminAuditLogItem(BaseModel):
    id: uuid.UUID
    admin_id: uuid.UUID | None
    action: str
    resource_type: str
    resource_id: str | None
    details: Dict[str, Any] | None
    created_at: datetime

    model_config = {"from_attributes": True}

class AdminAuditLogsResponse(BaseModel):
    logs: List[AdminAuditLogItem]
