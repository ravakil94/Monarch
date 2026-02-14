from fastapi import APIRouter


def health_router(service_name: str, version: str) -> APIRouter:
    router = APIRouter()

    @router.get("/health")
    async def health():
        return {"status": "UP", "service": service_name, "version": version}

    return router
