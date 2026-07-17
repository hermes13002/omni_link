import asyncio

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db
from app.db.models.device import Device
from app.services.device_service import get_device_by_plain_secret, touch_device_last_seen
from app.services.pubsub_service import open_user_channel_subscription

router = APIRouter(prefix="/stream", tags=["stream"])

_KEEPALIVE_TICKS = 20
_POLL_SLEEP_SECONDS = 0.05


@router.get("")
async def stream_inbox(
    request: Request,
    device_secret: str = Query(...),
    db: AsyncSession = Depends(get_db),
) -> StreamingResponse:
    device: Device | None = await get_device_by_plain_secret(device_secret, db)
    if device is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="invalid device secret",
        )

    await touch_device_last_seen(device, db)
    user_id = device.user_id

    async def event_generator():
        pubsub, channel = await open_user_channel_subscription(user_id)
        ticks_since_last_event = 0
        try:
            while True:
                if await request.is_disconnected():
                    break

                message = await pubsub.get_message(
                    ignore_subscribe_messages=True,
                    timeout=1.0,
                )
                if message and message.get("type") == "message":
                    raw_data = message["data"]
                    yield f"data: {raw_data}\n\n"
                    ticks_since_last_event = 0
                else:
                    ticks_since_last_event += 1
                    if ticks_since_last_event >= _KEEPALIVE_TICKS:
                        yield ": keepalive\n\n"
                        ticks_since_last_event = 0

                await asyncio.sleep(_POLL_SLEEP_SECONDS)

        except asyncio.CancelledError:
            pass
        except Exception as e:
            print(f"SSE stream error: {e}")
        finally:
            try:
                await pubsub.unsubscribe(channel)
                await pubsub.close()
            except Exception as cleanup_err:
                print(f"SSE stream cleanup error: {cleanup_err}")

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
