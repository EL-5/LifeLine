-- Lifeline Mesh - Initial Database Schema
-- AI-Powered Emergency Coordination & Medical Funding Infrastructure

-- ========================================
-- ENUMS
-- ========================================

CREATE TYPE user_role AS ENUM ('patient', 'family', 'community_supporter', 'driver', 'hospital', 'moderator', 'admin');
CREATE TYPE emergency_category AS ENUM ('accident', 'stroke', 'breathing_difficulty', 'pregnancy_emergency', 'child_emergency', 'chest_pain', 'violence_injury', 'unknown');
CREATE TYPE severity_level AS ENUM ('critical', 'serious', 'moderate', 'mild');
CREATE TYPE emergency_status AS ENUM ('pending', 'dispatched', 'driver_assigned', 'driver_arrived', 'en_route_hospital', 'arrived_hospital', 'in_treatment', 'completed', 'cancelled', 'flagged');
CREATE TYPE relationship_type AS ENUM ('parent', 'spouse', 'sibling', 'guardian', 'emergency_friend');
CREATE TYPE connection_status AS ENUM ('invited', 'accepted', 'rejected');
CREATE TYPE payment_method AS ENUM ('mobile_money', 'card', 'wallet', 'moolre');
CREATE TYPE payment_status AS ENUM ('pending', 'processing', 'completed', 'failed', 'refunded');
CREATE TYPE verification_status AS ENUM ('unverified', 'pending', 'verified', 'suspended');
CREATE TYPE payment_type AS ENUM ('driver_payout', 'hospital_deposit', 'refund', 'family_contribution', 'community_contribution');
CREATE TYPE validation_type AS ENUM ('community', 'ai', 'provider');
CREATE TYPE trust_event_status AS ENUM ('pending', 'verified', 'rejected');

-- ========================================
-- TABLES
-- ========================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role user_role NOT NULL DEFAULT 'patient',
    full_name TEXT,
    phone TEXT UNIQUE,
    email TEXT,
    profile_photo TEXT,
    trust_score FLOAT DEFAULT 0.0,
    verification_status verification_status DEFAULT 'unverified',
    device_id TEXT,
    fcm_token TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE hospitals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    location JSONB NOT NULL DEFAULT '{"lat": 0, "lng": 0, "address": ""}',
    emergency_capacity INT DEFAULT 0,
    verification_status verification_status DEFAULT 'unverified',
    contact_phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vehicle_type TEXT,
    vehicle_registration TEXT,
    availability_status BOOLEAN DEFAULT FALSE,
    verification_status verification_status DEFAULT 'unverified',
    current_location JSONB DEFAULT '{"lat": 0, "lng": 0}',
    total_earnings DECIMAL(12,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE emergencies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category emergency_category NOT NULL,
    symptoms TEXT[] DEFAULT '{}',
    severity severity_level DEFAULT 'moderate',
    location JSONB NOT NULL DEFAULT '{"lat": 0, "lng": 0, "address": ""}',
    hospital_id UUID REFERENCES hospitals(id),
    driver_id UUID REFERENCES drivers(id),
    status emergency_status DEFAULT 'pending',
    target_amount DECIMAL(12,2) DEFAULT 0.00,
    raised_amount DECIMAL(12,2) DEFAULT 0.00,
    fraud_flag BOOLEAN DEFAULT FALSE,
    ai_summary TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE family_connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    family_member_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    relationship_type relationship_type NOT NULL,
    status connection_status DEFAULT 'invited',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, family_member_id)
);

CREATE TABLE contributions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    emergency_id UUID NOT NULL REFERENCES emergencies(id) ON DELETE CASCADE,
    contributor_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(12,2) NOT NULL,
    payment_method payment_method DEFAULT 'mobile_money',
    payment_status payment_status DEFAULT 'pending',
    moolre_transaction_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    emergency_id UUID NOT NULL REFERENCES emergencies(id) ON DELETE CASCADE,
    payment_type payment_type NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    recipient_id UUID REFERENCES users(id),
    status payment_status DEFAULT 'pending',
    moolre_reference TEXT,
    released_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES users(id),
    action TEXT NOT NULL,
    resource_type TEXT,
    resource_id TEXT,
    metadata JSONB DEFAULT '{}',
    ip_address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE trust_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    emergency_id UUID NOT NULL REFERENCES emergencies(id) ON DELETE CASCADE,
    validator_id UUID NOT NULL REFERENCES users(id),
    validation_type validation_type NOT NULL,
    status trust_event_status DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- INDEXES
-- ========================================

CREATE INDEX idx_emergencies_status_created ON emergencies(status, created_at DESC);
CREATE INDEX idx_emergencies_patient ON emergencies(patient_id);
CREATE INDEX idx_contributions_emergency ON contributions(emergency_id);
CREATE INDEX idx_drivers_availability ON drivers(availability_status) WHERE availability_status = TRUE;
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_id, created_at DESC);
CREATE INDEX idx_trust_events_emergency ON trust_events(emergency_id);
CREATE INDEX idx_family_connections_user ON family_connections(user_id);
CREATE INDEX idx_payments_emergency ON payments(emergency_id);

-- ========================================
-- TRIGGERS
-- ========================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_emergencies_updated_at
    BEFORE UPDATE ON emergencies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_drivers_updated_at
    BEFORE UPDATE ON drivers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-update raised_amount on contributions
CREATE OR REPLACE FUNCTION update_raised_amount()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.payment_status = 'completed' THEN
        UPDATE emergencies
        SET raised_amount = raised_amount + NEW.amount
        WHERE id = NEW.emergency_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_contribution_completed
    AFTER INSERT OR UPDATE OF payment_status ON contributions
    FOR EACH ROW
    WHEN (NEW.payment_status = 'completed')
    EXECUTE FUNCTION update_raised_amount();

-- ========================================
-- ROW LEVEL SECURITY
-- ========================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE contributions ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE hospitals ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE trust_events ENABLE ROW LEVEL SECURITY;

-- Users: can read own profile, admins read all
CREATE POLICY users_self_access ON users
    FOR ALL USING (id = auth.uid());
CREATE POLICY users_admin_access ON users
    FOR SELECT USING (auth.jwt()->>'role' = 'admin');

-- Emergencies: patient owns, family sees, drivers see assigned, hospitals see incoming, admins see all
CREATE POLICY emergencies_patient_access ON emergencies
    FOR ALL USING (patient_id = auth.uid());
CREATE POLICY emergencies_family_access ON emergencies
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM family_connections WHERE emergency_id = emergencies.id AND family_member_id = auth.uid())
    );
CREATE POLICY emergencies_driver_access ON emergencies
    FOR SELECT USING (driver_id = auth.uid());
CREATE POLICY emergencies_hospital_access ON emergencies
    FOR SELECT USING (hospital_id = auth.uid());
CREATE POLICY emergencies_admin_access ON emergencies
    FOR ALL USING (auth.jwt()->>'role' = 'admin');

-- Drivers: own profile access
CREATE POLICY drivers_self_access ON drivers
    FOR ALL USING (user_id = auth.uid());

-- Hospitals: read own, admins manage
CREATE POLICY hospitals_read_all ON hospitals
    FOR SELECT USING (true);
CREATE POLICY hospitals_admin_manage ON hospitals
    FOR ALL USING (auth.jwt()->>'role' = 'admin');

-- Contributions: see own, see contributions to own emergencies
CREATE POLICY contributions_self ON contributions
    FOR ALL USING (contributor_id = auth.uid());
CREATE POLICY contributions_emergency_owner ON contributions
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM emergencies WHERE id = contributions.emergency_id AND patient_id = auth.uid())
    );

-- Payments: see own, admins see all
CREATE POLICY payments_self ON payments
    FOR SELECT USING (recipient_id = auth.uid());
CREATE POLICY payments_admin ON payments
    FOR ALL USING (auth.jwt()->>'role' = 'admin');

-- Audit logs: admins only
CREATE POLICY audit_logs_admin ON audit_logs
    FOR SELECT USING (auth.jwt()->>'role' = 'admin');

-- ========================================
-- SEED DATA (for development)
-- ========================================

INSERT INTO hospitals (name, location, emergency_capacity, verification_status, contact_phone) VALUES
    ('Korle Bu Teaching Hospital', '{"lat": 5.5333, "lng": -0.2167, "address": "Korle Bu, Accra"}', 50, 'verified', '+233302665101'),
    ('Komfo Anokye Teaching Hospital', '{"lat": 6.6667, "lng": -1.6167, "address": "Kumasi"}', 40, 'verified', '+233322032281'),
    ('Ridge Hospital', '{"lat": 5.5556, "lng": -0.2025, "address": "Ridge, Accra"}', 25, 'verified', '+233302228200'),
    ('37 Military Hospital', '{"lat": 5.5897, "lng": -0.1883, "address": "Accra"}', 30, 'verified', '+233302768100');