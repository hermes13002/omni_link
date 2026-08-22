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


_cached_sa_email: str | None = None
_cached_sa_token: str | None = None
_sa_token_expiry: float = 0

def _get_sa_email() -> str | None:
    global _cached_sa_email
    if _cached_sa_email:
        return _cached_sa_email
    try:
        import urllib.request
        req = urllib.request.Request(
            "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/email", 
            headers={"Metadata-Flavor": "Google"}
        )
        _cached_sa_email = urllib.request.urlopen(req, timeout=2).read().decode('utf-8').strip()
    except Exception as e:
        logger.error(f"Failed to fetch SA email: {e}")
    return _cached_sa_email

def _get_sa_token() -> str | None:
    global _cached_sa_token, _sa_token_expiry
    import time
    if _cached_sa_token and time.time() < _sa_token_expiry:
        return _cached_sa_token
    try:
        import urllib.request
        import json
        req = urllib.request.Request(
            "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token", 
            headers={"Metadata-Flavor": "Google"}
        )
        resp = urllib.request.urlopen(req, timeout=2).read().decode('utf-8')
        data = json.loads(resp)
        _cached_sa_token = data["access_token"]
        _sa_token_expiry = time.time() + data.get("expires_in", 3600) - 60
    except Exception as e:
        logger.error(f"Failed to fetch SA token: {e}")
    return _cached_sa_token

def _generate_signed_url_sync(blob: storage.Blob, kwargs: dict, client: storage.Client) -> str:
    # Cloud Run default credentials don't have a private key, so they must use the IAM API to sign URLs.
    # This requires both service_account_email and a valid access_token.
    creds = getattr(client, "_credentials", getattr(client, "credentials", None))
    if not hasattr(creds, "signer") or creds.signer is None:
        email = _get_sa_email()
        if email:
            kwargs["service_account_email"] = email

        token = _get_sa_token()
        if token:
            kwargs["access_token"] = token

    return blob.generate_signed_url(**kwargs)


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
        _generate_signed_url_sync,
        blob,
        kwargs,
        client,
    )
    return signed_url


async def delete_object(object_key: str) -> None:
    loop = asyncio.get_event_loop()
    client = get_gcs_client()
    bucket = client.bucket(settings.gcs_bucket_name)
    blob = bucket.blob(object_key)
    await loop.run_in_executor(None, blob.delete)
