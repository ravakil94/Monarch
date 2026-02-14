from fastapi import FastAPI
from app.routes import router

app = FastAPI(title="Policy Decision Service", version="0.1.0")
app.include_router(router)


@app.get("/health")
async def health():
    return {"status": "UP", "service": "policy-decision-service", "version": "0.1.0"}
