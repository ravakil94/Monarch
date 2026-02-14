# ADR-001: Architecture Decisions

**Status**: Accepted
**Date**: 2026-02-14

## Context

Monarch is a 13-platform wealth management system requiring sub-millisecond order processing, ACID-compliant financial ledgers, ML-powered risk analytics, and real-time portfolio calculations — all within one monorepo.

## Decisions

### 1. Polyglot Microservices
**Rust** for OMS (latency-critical), **Java** for ledger/onboarding (ACID/regulatory maturity), **Go** for portfolio (concurrent calculations), **Python** for risk/ML (numerical computing), **Node.js** for reporting/BFFs (async I/O).

### 2. Event-Driven (Kafka)
All state changes emit immutable events. Enables audit trail, eventual consistency, and service decoupling. Avro schemas via Schema Registry for contract enforcement.

### 3. Ledger-First
Cash and securities ledgers are the source of truth. Double-entry bookkeeping. All projections (positions, balances) are derivable from the event/ledger log.

### 4. Schema-per-Tenant (PostgreSQL)
Multi-tenancy via PostgreSQL schemas + Row Level Security. Data isolation for regulatory compliance, shared infra for cost efficiency.

### 5. Polyglot Persistence
8 databases, each optimized for its access pattern. PostgreSQL (ACID), TimescaleDB (time-series), ScyllaDB (high-throughput), Neo4j (graphs), Redis (cache), MongoDB (documents), Druid/ClickHouse (analytics).

### 6. Nx Monorepo
Single repository for all services across 5 languages. Contract-first development with shared event schemas and API specs.

## Consequences

- Higher initial setup complexity (5 language toolchains)
- Strong domain boundaries via event contracts
- Independent deployment per service
- Consistent patterns via shared libraries per language
