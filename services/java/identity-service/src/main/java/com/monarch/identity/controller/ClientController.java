package com.monarch.identity.controller;

import com.monarch.common.TenantContext;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/clients")
public class ClientController {

    @PostMapping
    public ResponseEntity<Map<String, Object>> createClient(@RequestBody Map<String, Object> body) {
        String clientId = UUID.randomUUID().toString();
        String tenantId = TenantContext.getTenantId();

        return ResponseEntity.status(201).body(Map.of(
                "client_id", clientId,
                "tenant_id", tenantId != null ? tenantId : "default",
                "status", "PENDING",
                "message", "Client created. KYC verification required."
        ));
    }

    @GetMapping("/{clientId}")
    public ResponseEntity<Map<String, Object>> getClient(@PathVariable String clientId) {
        return ResponseEntity.ok(Map.of(
                "client_id", clientId,
                "status", "PENDING",
                "message", "Stub response — persistence not yet wired"
        ));
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "service", "identity-service",
                "version", "0.1.0"
        ));
    }
}
