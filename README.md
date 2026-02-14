# Monarch

**India's Next-Gen Wealth, Broking & Asset Management Platform**

13 Platforms | 42 Microservices | Event-Driven | Ledger-First

---

## Architecture

- **Polyglot**: Java 21 (Spring Boot) + Rust (Actix) + Go (Gin) + Python (FastAPI) + Node.js (NestJS/Fastify) + Next.js + Flutter
- **Databases**: PostgreSQL 16 + MongoDB + Redis + TimescaleDB + ScyllaDB + Neo4j + Druid + ClickHouse
- **Events**: Apache Kafka + Schema Registry (Avro)
- **Auth**: Keycloak (multi-tenant RBAC/ABAC)
- **Infra**: Kubernetes (EKS) + Terraform + Istio + Vault

## Quick Start

```bash
# Start infrastructure
docker compose -f docker-compose.infra.yml up -d

# Start gateway
cd apps/gateway && npm install && npm run dev

# Start services (examples)
cd services/python/policy-decision-service && uvicorn app.main:app --port 8011
cd services/rust/order-capture-service && cargo run
```

## Monorepo Layout

```
apps/         → Web (Next.js), Mobile (Flutter), Gateway, BFFs
services/     → java/, rust/, go/, python/, node/
libs/         → Shared: types, UI kit, common-{java,rust,go,python}, event schemas, migrations
infrastructure/ → Terraform, K8s, Docker
docs/         → PRDs, ADRs, API specs, runbooks
```

## Platforms

| # | Platform | Language | Priority |
|---|---------|----------|----------|
| 1 | Client Onboarding | Java | Critical |
| 2 | Order Management | Rust | Critical |
| 3 | Portfolio Management | Go | High |
| 4 | Risk & Compliance | Python | Critical |
| 5 | Operations Control | Java | High |
| 6 | Reporting & Analytics | Node.js | Medium |
| 7 | Client DIY (Web+Mobile) | Next.js+Flutter | Medium |
| 8 | CRM | Java | Low |
| 9 | Proprietary Trading | C++/Rust | Critical |
| 10 | Treasury | Java | High |
| 11 | Market Data | Python | Critical |
| 12 | Institutional Services | Java | Medium |
| 13 | Wealth Advisory | Python | Low |

---

&copy; 2026 Monarch. All rights reserved.
