#!/bin/bash
# Creates Monarch Kafka topics. Run after Kafka is healthy.
# Usage: ./create-kafka-topics.sh [bootstrap-server]

BOOTSTRAP=${1:-localhost:9092}

TOPICS=(
  "kyc.status.changed"
  "policy.decisioned"
  "ips.approved"
  "ips.expired"
  "order.created"
  "order.validated"
  "order.submitted"
  "order.ack"
  "order.partial_fill"
  "order.filled"
  "order.cancelled"
  "order.rejected"
  "trade.executed"
  "trade.allocated"
  "settlement.completed"
  "settlement.failed"
  "ledger.cash.posted"
  "ledger.securities.posted"
  "recon.break.created"
  "recon.break.resolved"
  "portfolio.drift.detected"
  "rebalance.recommended"
  "rebalance.executed"
  "risk.alert.raised"
  "risk.alert.resolved"
  "ops.bod.completed"
  "ops.eod.completed"
)

for TOPIC in "${TOPICS[@]}"; do
  kafka-topics --bootstrap-server "$BOOTSTRAP" \
    --create --if-not-exists \
    --topic "$TOPIC" \
    --partitions 6 \
    --replication-factor 1 \
    --config retention.ms=604800000 \
    --config cleanup.policy=delete
  echo "Created topic: $TOPIC"
done

echo "All ${#TOPICS[@]} topics created."
