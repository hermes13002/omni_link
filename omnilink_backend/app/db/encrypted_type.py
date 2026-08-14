from sqlalchemy.types import TypeDecorator, Text
from cryptography.fernet import Fernet, InvalidToken
from app.config import settings
import logging

logger = logging.getLogger(__name__)
f = Fernet(settings.db_encryption_key)

class EncryptedText(TypeDecorator):
    """
    Transparently encrypts data before saving to the database
    and decrypts it when retrieving. Uses Fernet symmetric encryption.
    """
    impl = Text
    cache_ok = True

    def process_bind_param(self, value, dialect):
        if value is not None:
            return f.encrypt(value.encode('utf-8')).decode('utf-8')
        return value

    def process_result_value(self, value, dialect):
        if value is not None:
            try:
                return f.decrypt(value.encode('utf-8')).decode('utf-8')
            except InvalidToken:
                # Fallback to plaintext for smooth migration of legacy data
                logger.warning("Failed to decrypt a database field. Returning plaintext fallback.")
                return value
        return value
