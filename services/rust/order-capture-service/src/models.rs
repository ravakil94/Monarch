use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize)]
pub struct OrderRequest {
    pub client_id: String,
    pub instrument_id: String,
    pub exchange: String,
    pub product_type: String,
    pub order_type: String,    // MARKET, LIMIT, SL, SL_M
    pub side: String,          // BUY, SELL
    pub quantity: String,      // decimal as string
    pub price: Option<String>,
    pub trigger_price: Option<String>,
}

#[derive(Debug, Serialize)]
pub struct OrderResponse {
    pub order_id: String,
    pub status: String,
    pub created_at: String,
}
