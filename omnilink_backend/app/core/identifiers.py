import uuid
from typing import Annotated, Any

from pydantic import BeforeValidator, PlainSerializer

BASE62 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

def base62_encode(num: int) -> str:
    if num == 0:
        return BASE62[0]
    res = []
    while num > 0:
        num, rem = divmod(num, 62)
        res.append(BASE62[rem])
    return ''.join(reversed(res))

def base62_decode(s: str) -> int:
    res = 0
    for char in s:
        res = res * 62 + BASE62.index(char)
    return res

def _parse_prefixed_uuid(prefix: str):
    def validator(v: Any) -> uuid.UUID:
        if isinstance(v, uuid.UUID):
            return v
        if not isinstance(v, str):
            raise ValueError("ID must be a string")
        if not v.startswith(f"{prefix}_"):
            raise ValueError(f"ID must start with {prefix}_")
        encoded_part = v[len(prefix) + 1:]
        try:
            num = base62_decode(encoded_part)
            return uuid.UUID(int=num)
        except Exception:
            raise ValueError("Invalid ID encoding")
    return validator

def _serialize_prefixed_uuid(prefix: str):
    def serializer(v: uuid.UUID) -> str:
        encoded = base62_encode(v.int)
        return f"{prefix}_{encoded}"
    return serializer

def _parse_prefixed_int(prefix: str):
    def validator(v: Any) -> int:
        if isinstance(v, int):
            return v
        if not isinstance(v, str):
            raise ValueError("ID must be a string")
        if not v.startswith(f"{prefix}_"):
            raise ValueError(f"ID must start with {prefix}_")
        encoded_part = v[len(prefix) + 1:]
        try:
            return base62_decode(encoded_part)
        except Exception:
            raise ValueError("Invalid ID encoding")
    return validator

def _serialize_prefixed_int(prefix: str):
    def serializer(v: int) -> str:
        encoded = base62_encode(v)
        return f"{prefix}_{encoded}"
    return serializer

PrefixedUserId = Annotated[
    uuid.UUID,
    BeforeValidator(_parse_prefixed_uuid("usr")),
    PlainSerializer(_serialize_prefixed_uuid("usr"), return_type=str)
]

PrefixedCardId = Annotated[
    uuid.UUID,
    BeforeValidator(_parse_prefixed_uuid("card")),
    PlainSerializer(_serialize_prefixed_uuid("card"), return_type=str)
]

PrefixedDeviceId = Annotated[
    uuid.UUID,
    BeforeValidator(_parse_prefixed_uuid("dvc")),
    PlainSerializer(_serialize_prefixed_uuid("dvc"), return_type=str)
]

PrefixedTagId = Annotated[
    int,
    BeforeValidator(_parse_prefixed_int("tag")),
    PlainSerializer(_serialize_prefixed_int("tag"), return_type=str)
]
