import asyncio

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_db
from app.db.models.device import Device
from app.services.device_service import get_device_by_plain_secret, touch_device_last_seen
from app.services.pubsub_service import subscribe_user, unsubscribe_user

router = APIRouter(prefix="/stream", tags=["stream"])

_KEEPALIVE_TICKS = 20

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
        queue = await subscribe_user(user_id)
        ticks_since_last_event = 0
        try:
            while True:
                if await request.is_disconnected():
                    break

                try:
                    data = await asyncio.wait_for(queue.get(), timeout=1.0)
                    yield f"data: {data}\n\n"
                    ticks_since_last_event = 0
                except asyncio.TimeoutError:
                    ticks_since_last_event += 1
                    if ticks_since_last_event >= _KEEPALIVE_TICKS:
                        yield ": keepalive\n\n"
                        ticks_since_last_event = 0
                except asyncio.CancelledError:
                    break

        except Exception as e:
            print(f"SSE stream error: {e}")
        finally:
            unsubscribe_user(user_id, queue)

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )
