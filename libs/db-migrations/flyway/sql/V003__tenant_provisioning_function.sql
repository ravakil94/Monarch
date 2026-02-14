-- Function to provision a new tenant
CREATE OR REPLACE FUNCTION monarch_platform.provision_tenant(
    p_tenant_name VARCHAR,
    p_tenant_code VARCHAR,
    p_domain VARCHAR DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_tenant_id UUID;
    v_schema_name VARCHAR;
BEGIN
    -- Insert tenant record
    INSERT INTO monarch_platform.tenants (tenant_name, tenant_code, domain)
    VALUES (p_tenant_name, p_tenant_code, p_domain)
    RETURNING tenant_id INTO v_tenant_id;

    -- Create tenant schema
    v_schema_name := 'monarch_' || p_tenant_code;
    EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I', v_schema_name);

    -- Apply tenant template tables (V002 content) in the new schema
    EXECUTE format('SET search_path TO %I', v_schema_name);

    -- NOTE: In production, this would call the V002 template.
    -- For now, we log the provision event.
    INSERT INTO monarch_platform.audit_log (tenant_id, action, entity_type, entity_id, new_value)
    VALUES (v_tenant_id, 'TENANT_PROVISIONED', 'TENANT', v_tenant_id::VARCHAR,
            jsonb_build_object('schema', v_schema_name, 'tenant_code', p_tenant_code));

    RESET search_path;
    RETURN v_tenant_id;
END;
$$ LANGUAGE plpgsql;
