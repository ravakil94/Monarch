# @monarch/event-schemas

Avro schema definitions for the Monarch wealth management platform's Kafka event-driven architecture. These schemas serve as the canonical event contracts between services.

## Schema inventory

| File | Namespace | Description |
|------|-----------|-------------|
| `avro/common.avsc` | `com.monarch.events` | `MonarchEventHeader` — shared header embedded in every event |
| `avro/kyc-status-changed.avsc` | `com.monarch.events.kyc` | KYC verification status transitions |
| `avro/order-event.avsc` | `com.monarch.events.order` | Full order lifecycle (create through fill/cancel) |
| `avro/ledger-posted.avsc` | `com.monarch.events.ledger` | Double-entry ledger postings (cash and securities) |
| `avro/policy-decisioned.avsc` | `com.monarch.events.policy` | Policy engine decisions (approve/reject/review) |
| `avro/recon-break.avsc` | `com.monarch.events.recon` | Reconciliation break detection and lifecycle |

## Design conventions

- **Header pattern** — Every event embeds `MonarchEventHeader` which carries `event_id`, `event_type`, `tenant_id`, `timestamp`, optional `correlation_id`, and `caused_by` for causal lineage.
- **Decimal-as-string** — Monetary amounts and quantities are encoded as strings to preserve arbitrary decimal precision and avoid floating-point representation issues.
- **Nullable unions** — Optional fields use `["null", "type"]` unions with `"default": null` so producers can omit them safely.
- **Namespace hierarchy** — `com.monarch.events.<domain>` keeps schemas organized by bounded context.

## Usage

These `.avsc` files are designed to be:

1. Registered in a **Confluent Schema Registry** (or compatible) for runtime serialization/deserialization.
2. Used by code-generation tools (`avro-tools`, `avsc`, `avro4k`, etc.) to produce typed classes in Java, TypeScript, Kotlin, or Python.
3. Referenced by consumer and producer services as the single source of truth for event shapes.

## Adding a new schema

1. Create a new `.avsc` file under `avro/`.
2. Choose the appropriate namespace under `com.monarch.events.<domain>`.
3. Embed `com.monarch.events.MonarchEventHeader` as the first field.
4. Use decimal-as-string for any monetary or quantity values.
5. Document every field with a `"doc"` annotation.
6. Update this README's schema inventory table.
