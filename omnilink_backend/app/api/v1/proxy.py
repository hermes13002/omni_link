import httpx
from fastapi import APIRouter, Query, Response

router = APIRouter(prefix="/proxy", tags=["proxy"])

@router.get("")
async def fetch_url(url: str = Query(..., description="The URL to proxy")):
    """
    Proxies a GET request to bypass CORS restrictions on the frontend.
    """
    async with httpx.AsyncClient() as client:
        try:
            r = await client.get(url, follow_redirects=True, timeout=10.0)
            return Response(
                content=r.content,
                status_code=r.status_code,
                media_type=r.headers.get("content-type", "text/html"),
            )
        except Exception as e:
            return Response(
                content=f"Error fetching URL: {str(e)}",
                status_code=500,
                media_type="text/plain",
            )
