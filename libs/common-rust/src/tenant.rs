use actix_web::{HttpRequest, HttpResponse, dev::ServiceRequest};
use serde::{Deserialize, Serialize};

pub const TENANT_HEADER: &str = "X-Tenant-Id";

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TenantContext {
    pub tenant_id: String,
}

impl TenantContext {
    pub fn from_request(req: &HttpRequest) -> Option<Self> {
        req.headers()
            .get(TENANT_HEADER)
            .and_then(|v| v.to_str().ok())
            .filter(|s| !s.is_empty())
            .map(|id| TenantContext {
                tenant_id: id.to_string(),
            })
    }
}
