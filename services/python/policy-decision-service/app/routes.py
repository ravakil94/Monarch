from fastapi import APIRouter, Header
from pydantic import BaseModel
from uuid import uuid4
from datetime import datetime, timezone

router = APIRouter(prefix="/api/v1/policy")


class PolicyRequest(BaseModel):
    subject_type: str  # ORDER, ONBOARDING, REBALANCING, WITHDRAWAL
    subject_id: str
    client_id: str
    context: dict = {}


class PolicyResponse(BaseModel):
    decision_id: str
    decision: str  # APPROVED, REJECTED, NEEDS_REVIEW
    reason_codes: list[str]
    evaluated_at: str


@router.post("/evaluate", response_model=PolicyResponse)
async def evaluate_policy(
    req: PolicyRequest,
    x_tenant_id: str | None = Header(None),
):
    """Evaluate policy rules against a subject. Stub implementation."""
    return PolicyResponse(
        decision_id=str(uuid4()),
        decision="APPROVED",
        reason_codes=["STUB_APPROVED"],
        evaluated_at=datetime.now(timezone.utc).isoformat(),
    )
