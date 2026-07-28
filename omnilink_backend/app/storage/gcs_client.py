import asyncio
from datetime import timedelta
from functools import partial

from google.cloud import storage

from app.config import settings

_gcs_client: storage.Client | None = None


import logging
from google.auth.exceptions import DefaultCredentialsError

logger = logging.getLogger(__name__)

def init_gcs_client() -> storage.Client | None:
    global _gcs_client
    try:
        _gcs_client = storage.Client()
    except DefaultCredentialsError:
        logger.warning("GCS credentials not found. File uploads will fail. To fix, set GOOGLE_APPLICATION_CREDENTIALS in .env or run `gcloud auth application-default login`.")
        _gcs_client = None
    return _gcs_client


def get_gcs_client() -> storage.Client:
    if _gcs_client is None:
        raise RuntimeError("gcs client is not initialized")
    return _gcs_client


async def upload_file_bytes(object_key: str, data: bytes, content_type: str) -> None:
    loop = asyncio.get_event_loop()
    client = get_gcs_client()
    bucket = client.bucket(settings.gcs_bucket_name)
    blob = bucket.blob(object_key)
    await loop.run_in_executor(
        None,
        partial(blob.upload_from_string, data, content_type=content_type),
    )


async def upload_file_stream(object_key: str, file_obj, content_type: str) -> None:
    loop = asyncio.get_event_loop()
    client = get_gcs_client()
    bucket = client.bucket(settings.gcs_bucket_name)
    blob = bucket.blob(object_key)
    await loop.run_in_executor(
        None,
        partial(blob.upload_from_file, file_obj, content_type=content_type),
    )


async def generate_signed_url(object_key: str, download_filename: str | None = None) -> str:
    loop = asyncio.get_event_loop()
    client = get_gcs_client()
    bucket = client.bucket(settings.gcs_bucket_name)
    blob = bucket.blob(object_key)
    expiration = timedelta(minutes=settings.gcs_signed_url_expire_minutes)
    
    kwargs = {
        "expiration": expiration,
        "method": "GET",
        "version": "v4",
    }
    if download_filename:
        kwargs["response_disposition"] = f'attachment; filename="{download_filename}"'

    signed_url: str = await loop.run_in_executor(
        None,
        partial(
            blob.generate_signed_url,
            **kwargs
        ),
    )
    return signed_url


async def delete_object(object_key: str) -> None:
    loop = asyncio.get_event_loop()
    client = get_gcs_client()
    bucket = client.bucket(settings.gcs_bucket_name)
    blob = bucket.blob(object_key)
    await loop.run_in_executor(None, blob.delete)
