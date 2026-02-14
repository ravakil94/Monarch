-- Tenant Schema Template
-- This script is parameterized: replace ${tenant_schema} with actual tenant schema name

-- Clients
CREATE TABLE clients (
    client_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_code VARCHAR(20) NOT NULL UNIQUE, -- UCC
    client_type VARCHAR(20) NOT NULL, -- INDIVIDUAL, JOINT, HUF, CORPORATE, TRUST, MINOR
    holding_pattern VARCHAR(30), -- SINGLE, JOINT, EITHER_OR_SURVIVOR, ANYONE_OR_SURVIVOR
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, ACTIVE, DORMANT, FROZEN, CLOSED
    engagement_mode VARCHAR(20), -- ADVISORY, DISCRETIONARY, EXECUTION_ONLY
    rm_id UUID,
    household_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_clients_status ON clients(status);
CREATE INDEX idx_clients_rm ON clients(rm_id);
CREATE INDEX idx_clients_household ON clients(household_id);

-- KYC Records
CREATE TABLE client_kyc (
    kyc_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(client_id),
    kyc_type VARCHAR(20) NOT NULL,
    kyc_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    aadhaar_reference_id VARCHAR(50),
    pan_number VARCHAR(10),
    pan_verified BOOLEAN DEFAULT FALSE,
    ckyc_number VARCHAR(14),
    video_kyc_session_id VARCHAR(50),
    aml_risk_score INTEGER,
    pep_flag BOOLEAN DEFAULT FALSE,
    sanctions_flag BOOLEAN DEFAULT FALSE,
    fatca_status VARCHAR(20),
    documents JSONB,
    verified_by VARCHAR(100),
    verified_at TIMESTAMPTZ,
    expiry_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT valid_kyc_status CHECK (kyc_status IN ('PENDING','VERIFIED','REJECTED','EXPIRED'))
);

CREATE INDEX idx_kyc_client ON client_kyc(client_id);
CREATE INDEX idx_kyc_pan ON client_kyc(pan_number);

-- Client Profile
CREATE TABLE client_profile (
    profile_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(client_id),
    date_of_birth DATE,
    gender VARCHAR(10),
    marital_status VARCHAR(20),
    occupation VARCHAR(100),
    employer VARCHAR(200),
    city VARCHAR(100),
    tier_classification VARCHAR(10),
    annual_income_range VARCHAR(20),
    declared_net_worth DECIMAL(18,2),
    existing_investments JSONB,
    liabilities JSONB,
    monthly_expenses DECIMAL(12,2),
    risk_tolerance_self VARCHAR(20),
    risk_capacity_computed VARCHAR(20),
    investment_experience_years INTEGER,
    investment_types_experienced TEXT[],
    accredited_investor BOOLEAN DEFAULT FALSE,
    pep_flag BOOLEAN DEFAULT FALSE,
    fatca_classification VARCHAR(50),
    crs_tax_residency TEXT[],
    profile_completeness_pct INTEGER DEFAULT 0,
    last_reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Risk Profiles
CREATE TABLE risk_profiles (
    risk_profile_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(client_id),
    risk_score_questionnaire INTEGER,
    risk_capacity_score INTEGER,
    risk_appetite_score INTEGER,
    final_risk_score INTEGER,
    risk_classification VARCHAR(20),
    classification_method VARCHAR(20),
    profile_status VARCHAR(20) DEFAULT 'ACTIVE',
    review_due_date DATE,
    questionnaire_responses JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Financial Goals
CREATE TABLE financial_goals (
    goal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(client_id),
    goal_name VARCHAR(200),
    goal_type VARCHAR(50),
    target_amount DECIMAL(18,2),
    current_value DECIMAL(18,2),
    monthly_contribution DECIMAL(12,2),
    target_date DATE,
    achievement_probability_pct DECIMAL(5,2),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Investment Policy Statements
CREATE TABLE investment_policy_statements (
    ips_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(client_id),
    goal_id UUID REFERENCES financial_goals(goal_id),
    ips_name VARCHAR(200),
    risk_profile_id UUID REFERENCES risk_profiles(risk_profile_id),
    target_allocation JSONB,
    permitted_asset_classes TEXT[],
    restricted_instruments TEXT[],
    max_single_stock_pct DECIMAL(5,2),
    min_credit_rating VARCHAR(5),
    leverage_permitted BOOLEAN DEFAULT FALSE,
    target_return_pct DECIMAL(5,2),
    max_drawdown_pct DECIMAL(5,2),
    investment_horizon_months INTEGER,
    rebalancing_frequency VARCHAR(20),
    rebalancing_drift_threshold_pct DECIMAL(5,2),
    status VARCHAR(20) DEFAULT 'DRAFT',
    signed_at TIMESTAMPTZ,
    document_id UUID,
    effective_from DATE,
    effective_to DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Orders
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(client_id),
    exchange_order_id VARCHAR(50),
    instrument_id VARCHAR(20) NOT NULL,
    exchange VARCHAR(10) NOT NULL,
    product_type VARCHAR(20) NOT NULL,
    order_type VARCHAR(10) NOT NULL,
    side VARCHAR(4) NOT NULL,
    quantity DECIMAL(18,4) NOT NULL,
    price DECIMAL(18,4),
    trigger_price DECIMAL(18,4),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    filled_quantity DECIMAL(18,4) DEFAULT 0,
    average_fill_price DECIMAL(18,4),
    validation_result JSONB,
    margin_blocked DECIMAL(18,2),
    settlement_date DATE,
    settlement_status VARCHAR(20),
    routed_via VARCHAR(50),
    algo_strategy_id UUID,
    placed_by VARCHAR(100),
    placed_via VARCHAR(20),
    ip_address INET,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    exchange_timestamp TIMESTAMPTZ
);

CREATE INDEX idx_orders_client ON orders(client_id, created_at DESC);
CREATE INDEX idx_orders_status ON orders(status) WHERE status NOT IN ('FILLED','CANCELLED');
CREATE INDEX idx_orders_exchange ON orders(exchange, exchange_order_id);
CREATE INDEX idx_orders_instrument ON orders(instrument_id, created_at DESC);

-- Order Events (immutable audit trail)
CREATE TABLE order_events (
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(order_id),
    event_type VARCHAR(30) NOT NULL,
    event_data JSONB,
    event_timestamp TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_order_events ON order_events(order_id, event_timestamp);

-- Cash Ledger (double-entry)
CREATE TABLE cash_ledger (
    entry_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    account_type VARCHAR(20) NOT NULL, -- CLIENT, PROPRIETARY, SETTLEMENT
    client_id UUID REFERENCES clients(client_id),
    entry_type VARCHAR(20) NOT NULL, -- DEBIT, CREDIT
    amount DECIMAL(18,2) NOT NULL,
    balance_after DECIMAL(18,2) NOT NULL,
    reference_type VARCHAR(30) NOT NULL, -- ORDER, SETTLEMENT, FEE, TRANSFER, CORPORATE_ACTION
    reference_id UUID NOT NULL,
    narration TEXT,
    value_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_cash_ledger_account ON cash_ledger(account_id, created_at DESC);
CREATE INDEX idx_cash_ledger_client ON cash_ledger(client_id, created_at DESC);
CREATE INDEX idx_cash_ledger_ref ON cash_ledger(reference_type, reference_id);

-- Securities Ledger (double-entry)
CREATE TABLE securities_ledger (
    entry_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL,
    client_id UUID REFERENCES clients(client_id),
    instrument_id VARCHAR(20) NOT NULL,
    entry_type VARCHAR(20) NOT NULL, -- DEBIT, CREDIT
    quantity DECIMAL(18,4) NOT NULL,
    balance_after DECIMAL(18,4) NOT NULL,
    reference_type VARCHAR(30) NOT NULL,
    reference_id UUID NOT NULL,
    narration TEXT,
    value_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_sec_ledger_account ON securities_ledger(account_id, instrument_id, created_at DESC);
CREATE INDEX idx_sec_ledger_client ON securities_ledger(client_id, instrument_id, created_at DESC);

-- Model Portfolios
CREATE TABLE model_portfolios (
    model_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_name VARCHAR(100),
    risk_classification VARCHAR(20),
    description TEXT,
    version INTEGER DEFAULT 1,
    allocation JSONB,
    benchmark_index VARCHAR(50),
    backtested_returns JSONB,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Client Portfolios
CREATE TABLE client_portfolios (
    portfolio_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(client_id),
    portfolio_name VARCHAR(200),
    model_id UUID REFERENCES model_portfolios(model_id),
    ips_id UUID REFERENCES investment_policy_statements(ips_id),
    goal_id UUID REFERENCES financial_goals(goal_id),
    target_allocation JSONB,
    current_allocation JSONB,
    drift_pct DECIMAL(5,2),
    total_value DECIMAL(18,2),
    total_invested DECIMAL(18,2),
    unrealized_pnl DECIMAL(18,2),
    xirr DECIMAL(8,4),
    last_rebalanced_at TIMESTAMPTZ,
    next_review_date DATE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Documents Vault
CREATE TABLE documents (
    document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(client_id),
    category VARCHAR(50) NOT NULL,
    filename VARCHAR(255) NOT NULL,
    s3_key VARCHAR(500) NOT NULL,
    content_type VARCHAR(100),
    file_size_bytes BIGINT,
    checksum VARCHAR(64),
    encryption_key_id VARCHAR(100),
    ocr_extracted_data JSONB,
    verified BOOLEAN DEFAULT FALSE,
    verified_by VARCHAR(100),
    verified_at TIMESTAMPTZ,
    version INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    retention_until DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_documents_client ON documents(client_id, category);

-- Reconciliation Breaks
CREATE TABLE recon_breaks (
    break_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    break_type VARCHAR(30) NOT NULL,
    severity VARCHAR(10) NOT NULL,
    source_system VARCHAR(50) NOT NULL,
    target_system VARCHAR(50) NOT NULL,
    expected_value VARCHAR(100),
    actual_value VARCHAR(100),
    difference VARCHAR(100),
    client_id UUID REFERENCES clients(client_id),
    instrument_id VARCHAR(20),
    assigned_to VARCHAR(100),
    sla_deadline TIMESTAMPTZ,
    status VARCHAR(20) NOT NULL DEFAULT 'CREATED',
    resolution_notes TEXT,
    evidence_document_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_recon_breaks_status ON recon_breaks(status) WHERE status NOT IN ('RESOLVED');

-- Policy Decisions (audit trail)
CREATE TABLE policy_decisions (
    decision_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_version_id UUID NOT NULL,
    subject_type VARCHAR(30) NOT NULL,
    subject_id UUID NOT NULL,
    client_id UUID REFERENCES clients(client_id),
    decision VARCHAR(20) NOT NULL,
    reason_codes TEXT[],
    details JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_policy_decisions_subject ON policy_decisions(subject_type, subject_id);
