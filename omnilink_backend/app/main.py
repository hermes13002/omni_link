from contextlib import asynccontextmanager
from collections.abc import AsyncGenerator

from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.api.v1.router import router
from app.schemas.response import ApiResponse
from app.cache.redis_client import close_redis_pool, init_redis_pool
from app.core.middleware import RequestIdMiddleware, ContentSizeLimitMiddleware, SecureHeadersMiddleware
from app.core.rate_limit import limiter
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from app.storage.gcs_client import init_gcs_client
from app.config import settings

from app.services.pubsub_service import start_multiplexer, stop_multiplexer


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator:
    # run alembic upgrade head to create new tables on startup
    try:
        import alembic.config
        import alembic.command
        alembic_cfg = alembic.config.Config("alembic.ini")
        alembic.command.upgrade(alembic_cfg, "head")
        print("Successfully ran alembic upgrade head")
    except Exception as e:
        print(f"Alembic upgrade failed: {e}")
        
    await init_redis_pool()
    start_multiplexer()
    init_gcs_client()
    yield
    await stop_multiplexer()
    await close_redis_pool()


app = FastAPI(
    title="OmniLink API",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs" if settings.environment != "production" else None,
    redoc_url="/redoc" if settings.environment != "production" else None,
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(SlowAPIMiddleware)
app.add_middleware(SecureHeadersMiddleware)
app.add_middleware(RequestIdMiddleware)
# 50MB limit
app.add_middleware(ContentSizeLimitMiddleware, max_upload_size=50 * 1024 * 1024)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)


@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException) -> JSONResponse:
    content = ApiResponse(success=False, message=str(exc.detail)).model_dump()
    headers = getattr(exc, "headers", None)
    return JSONResponse(status_code=exc.status_code, content=content, headers=headers)


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
    content = ApiResponse(success=False, message="Validation error", data={"errors": exc.errors()}).model_dump()
    return JSONResponse(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, content=content)


@app.api_route("/", methods=["GET", "HEAD"], tags=["health"])
@app.api_route("/health", methods=["GET", "HEAD"], tags=["health"])
async def health_check() -> ApiResponse[dict]:
    return ApiResponse(data={"status": "ok"})
