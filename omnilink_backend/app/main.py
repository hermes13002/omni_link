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
from app.core.middleware import RequestIdMiddleware, ContentSizeLimitMiddleware
from app.core.rate_limit import limiter
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from app.storage.gcs_client import init_gcs_client


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator:
    await init_redis_pool()
    init_gcs_client()
    yield
    await close_redis_pool()


app = FastAPI(
    title="OmniLink API",
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

app.add_middleware(RequestIdMiddleware)
# 50MB limit
app.add_middleware(ContentSizeLimitMiddleware, max_upload_size=50 * 1024 * 1024)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
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


@app.get("/health", tags=["health"])
async def health_check() -> ApiResponse[dict]:
    return ApiResponse(data={"status": "ok"})
