from fastapi import APIRouter

from app.api.v1 import auth, cards, devices, push, stream, tags

router = APIRouter(prefix="/api/v1")

router.include_router(auth.router)
router.include_router(devices.router)
router.include_router(cards.router)
router.include_router(tags.router)
router.include_router(push.router)
router.include_router(stream.router)
