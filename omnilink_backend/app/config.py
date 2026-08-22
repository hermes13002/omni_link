import os
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    database_url: str
    database_ssl: bool = False
    redis_url: str
    gcs_bucket_name: str
    google_application_credentials: str | None = None
    jwt_secret: str
    admin_secret_key: str = "default_unsafe_secret"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 30
    gcs_signed_url_expire_minutes: int = 60
    environment: str = "development"
    db_encryption_key: str
    cors_origins: list[str] = ["*"]

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


settings = Settings()

if settings.google_application_credentials:
    if settings.google_application_credentials.strip().startswith("{"):
        import tempfile
        fd, path = tempfile.mkstemp(suffix=".json")
        with os.fdopen(fd, 'w') as f:
            f.write(settings.google_application_credentials)
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = path
    else:
        os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = settings.google_application_credentials
