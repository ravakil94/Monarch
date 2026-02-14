from contextvars import ContextVar
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

TENANT_HEADER = "X-Tenant-Id"
_tenant_ctx: ContextVar[str | None] = ContextVar("tenant_id", default=None)


class TenantContext:
    @staticmethod
    def get() -> str | None:
        return _tenant_ctx.get()

    @staticmethod
    def set(tenant_id: str) -> None:
        _tenant_ctx.set(tenant_id)


class TenantMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        tenant_id = request.headers.get(TENANT_HEADER)
        if tenant_id:
            TenantContext.set(tenant_id.strip())
        response = await call_next(request)
        return response


def tenant_middleware(app):
    app.add_middleware(TenantMiddleware)
