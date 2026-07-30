import enum
from sqlalchemy import Enum

class UserRole(str, enum.Enum):
    USER = "user"
    ADMIN = "admin"

e = Enum(UserRole)
print(e.enums)
