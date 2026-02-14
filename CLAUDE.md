# Monarch — Claude Code Instructions

## What Is This
India's integrated Wealth + Broking + Asset Management platform.
13 Platforms, 42 microservices, event-driven, ledger-first, schema-per-tenant.

## Monorepo Layout
```
apps/         → web (Next.js), mobile (Flutter), gateway, BFFs (NestJS)
services/     → java/ | rust/ | go/ | python/ | node/
libs/         → shared-types, ui-kit, api-client, common-{java,rust,go,python}, event-schemas, db-migrations
infrastructure/ → terraform, kubernetes, docker, scripts
docs/         → reference/, architecture/, api-specs/, event-catalog/, db-schemas/, runbooks/
tools/        → generators, seed-data, scripts
```

## Tech Stack
- **Java 21** (Spring Boot 3.2): Identity, KYC, ledger, settlement, ops, CRM, treasury
- **Rust** (Actix-Web): OMS critical path — order capture/validation/routing, trade processing, prop trading
- **Go** (Gin): Portfolio engine, model portfolios, rebalancing
- **Python** (FastAPI): Policy/compliance brain, risk profiling, surveillance, market data, advisory
- **Node.js** (NestJS): Notification, reporting, analytics, BFFs
- **Next.js 14+**: Web frontend (App Router, RSC)
- **Flutter 3.x**: Mobile (iOS + Android)

## Databases
PG16 (transactional), MongoDB (profiles/KYC), Redis7 (cache), TimescaleDB (market data), ScyllaDB (order book), Neo4j5 (family graphs), Druid (OLAP), ClickHouse (analytics)

## Infra
Kafka 3.6 + Schema Registry (Avro), Keycloak 24 (multi-tenant auth), Kong (gateway), Istio (mesh), Vault (secrets), K8s (EKS)

## Core Principles
1. Ledger-first: Cash & securities ledgers are source of truth
2. Policy brain: Centralized compliance engine shared by all channels
3. Household-first: Family/entity structures in data model from day 1
4. Event-driven: Kafka event log is immutable, services react to events
5. Contract-first: OpenAPI + Avro schemas defined before code
6. Always-on controls: Real-time reconciliation, not just EOD batch

## Coding Conventions
- Each service owns its own database schema — no cross-service DB access
- All IDs: UUID v7 (time-sortable)
- Multi-tenancy: schema-per-tenant (PG) + tenant_id in JWT + RLS
- Events: Avro schemas in `libs/event-schemas/`, topic naming: `{domain}.{entity}.{action}`
- API specs: OpenAPI 3.1 in `docs/api-specs/{service-name}.yaml`
- Migrations: Flyway (Java), custom scripts (others) in `libs/db-migrations/`
- Error responses: RFC 7807 Problem Details
- Logging: Structured JSON, correlation_id propagated via headers
- Tests: Unit + integration per service, contract tests for API boundaries

## Phase Status
- **Phase 0** (Foundation): Monorepo scaffolded, docker-compose, event schemas, shared libs, gateway, first service skeletons — IN PROGRESS
- Full plan: `docs/reference/` and `/Users/rav/.claude/plans/peaceful-hopping-stearns.md`

## Working With This Repo
- Start infra: `docker compose -f docker-compose.infra.yml up -d`
- Nx commands: `./nx build <project>`, `./nx test <project>`, `./nx graph`
- When working on a specific service, focus on that service's directory — don't load the entire repo
- Reference docs in `docs/reference/` — read on demand, not every session
- For the full implementation plan, read `/Users/rav/.claude/plans/peaceful-hopping-stearns.md`

## Quality Bar
- Production-grade from day 1. No shortcuts.
- Security: OWASP top 10 awareness, zero-trust, encrypt everything
- Performance: Sub-ms for OMS, <100ms for policy decisions
- Every service must have health check, structured logging, tenant isolation
