package com.monarch.common;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class AuditLogger {

    private static final Logger log = LoggerFactory.getLogger(AuditLogger.class);
    private final JdbcTemplate jdbc;

    public AuditLogger(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public void log(String action, String entityType, String entityId,
                    Object oldValue, Object newValue) {
        String tenantId = TenantContext.getTenantId();
        try {
            jdbc.update("""
                INSERT INTO monarch_platform.audit_log
                (audit_id, tenant_id, action, entity_type, entity_id, old_value, new_value)
                VALUES (?::uuid, ?::uuid, ?, ?, ?, ?::jsonb, ?::jsonb)
                """,
                UUID.randomUUID().toString(), tenantId, action, entityType, entityId,
                oldValue != null ? oldValue.toString() : null,
                newValue != null ? newValue.toString() : null);
        } catch (Exception e) {
            log.error("Failed to write audit log: {} {} {}", action, entityType, entityId, e);
        }
    }
}
