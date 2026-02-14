use actix_web::{get, HttpResponse, web};
use serde::Serialize;

#[derive(Serialize)]
struct HealthResponse {
    status: &'static str,
    service: String,
    version: String,
}

pub fn health_config(service_name: &'static str, version: &'static str) -> impl Fn(&mut web::ServiceConfig) + Clone {
    let name = service_name.to_string();
    let ver = version.to_string();
    move |cfg: &mut web::ServiceConfig| {
        let n = name.clone();
        let v = ver.clone();
        cfg.route("/health", web::get().to(move || {
            let n = n.clone();
            let v = v.clone();
            async move {
                HttpResponse::Ok().json(HealthResponse {
                    status: "UP",
                    service: n,
                    version: v,
                })
            }
        }));
    }
}
