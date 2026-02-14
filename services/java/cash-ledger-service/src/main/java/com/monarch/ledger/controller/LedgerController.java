package com.monarch.ledger.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/ledger/cash")
public class LedgerController {

    @PostMapping("/post")
    public ResponseEntity<Map<String, Object>> postEntry(@RequestBody Map<String, Object> body) {
        // Double-entry: every posting creates a debit + credit pair
        String entryId = UUID.randomUUID().toString();

        return ResponseEntity.status(201).body(Map.of(
                "entry_id", entryId,
                "status", "POSTED",
                "posted_at", Instant.now().toString(),
                "message", "Stub — double-entry posting skeleton"
        ));
    }

    @GetMapping("/balance/{accountId}")
    public ResponseEntity<Map<String, Object>> getBalance(@PathVariable String accountId) {
        return ResponseEntity.ok(Map.of(
                "account_id", accountId,
                "balance", BigDecimal.ZERO,
                "currency", "INR",
                "as_of", Instant.now().toString()
        ));
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "service", "cash-ledger-service",
                "version", "0.1.0"
        ));
    }
}
