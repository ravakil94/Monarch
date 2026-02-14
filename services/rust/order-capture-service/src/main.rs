use actix_web::{web, App, HttpServer, HttpResponse, HttpRequest};
use monarch_common::health::health_config;
use monarch_common::tenant::TenantContext;
use serde::{Deserialize, Serialize};
use uuid::Uuid;
use chrono::Utc;

mod models;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    tracing_subscriber::fmt::init();
    tracing::info!("Starting order-capture-service on :8001");

    HttpServer::new(|| {
        App::new()
            .configure(health_config("order-capture-service", "0.1.0"))
            .service(
                web::scope("/api/v1/orders")
                    .route("", web::post().to(capture_order))
            )
    })
    .bind("0.0.0.0:8001")?
    .run()
    .await
}

async fn capture_order(req: HttpRequest, body: web::Json<models::OrderRequest>) -> HttpResponse {
    let tenant = TenantContext::from_request(&req);
    let order_id = Uuid::new_v4().to_string();

    tracing::info!(
        order_id = %order_id,
        tenant = ?tenant.as_ref().map(|t| &t.tenant_id),
        instrument = %body.instrument_id,
        side = %body.side,
        "Order captured"
    );

    HttpResponse::Created().json(models::OrderResponse {
        order_id,
        status: "CREATED".to_string(),
        created_at: Utc::now().to_rfc3339(),
    })
}
