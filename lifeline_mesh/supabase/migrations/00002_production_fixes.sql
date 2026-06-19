-- ============================================================
-- Lifeline Mesh — Production Fixes Migration
-- 00002_production_fixes.sql
-- Run this AFTER 00001_initial_schema.sql
-- ============================================================

-- ============================================================
-- CLEANUP (Ensures this script can be re-run safely)
-- ============================================================
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS driver_location_updates CASCADE;
DROP VIEW IF EXISTS admin_stats CASCADE;
DROP VIEW IF EXISTS wallet_summary CASCADE;

-- ============================================================
-- 1. NOTIFICATIONS TABLE (missing — crashes create-emergency)
-- ============================================================

CREATE TABLE IF NOT EXISTS notifications (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title       TEXT NOT NULL,
    body        TEXT,
    data        JSONB DEFAULT '{}',
    read        BOOLEAN DEFAULT FALSE,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON notifications(user_id, read) WHERE read = FALSE;

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY notifications_self ON notifications
    FOR ALL USING (user_id = auth.uid());

-- ============================================================
-- 2. DRIVER LOCATION UPDATES (real-time GPS tracking)
-- ============================================================

CREATE TABLE IF NOT EXISTS driver_location_updates (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id   UUID NOT NULL REFERENCES drivers(id) ON DELETE CASCADE,
    emergency_id UUID REFERENCES emergencies(id) ON DELETE SET NULL,
    lat         DOUBLE PRECISION NOT NULL,
    lng         DOUBLE PRECISION NOT NULL,
    heading     DOUBLE PRECISION DEFAULT 0,
    speed       DOUBLE PRECISION DEFAULT 0,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_driver_location_driver ON driver_location_updates(driver_id, created_at DESC);
CREATE INDEX idx_driver_location_emergency ON driver_location_updates(emergency_id, created_at DESC);

ALTER TABLE driver_location_updates ENABLE ROW LEVEL SECURITY;

-- Drivers write their own location; patients/hospitals/admins can read during active emergency
CREATE POLICY driver_location_write ON driver_location_updates
    FOR INSERT WITH CHECK (
        driver_id = (SELECT id FROM drivers WHERE user_id = auth.uid())
    );

CREATE POLICY driver_location_read ON driver_location_updates
    FOR SELECT USING (
        driver_id = (SELECT id FROM drivers WHERE user_id = auth.uid())
        OR EXISTS (
            SELECT 1 FROM emergencies e
            WHERE e.id = driver_location_updates.emergency_id
              AND (e.patient_id = auth.uid()
                   OR e.hospital_id = auth.uid()
                   OR auth.jwt()->>'role' IN ('admin', 'moderator'))
        )
    );

-- ============================================================
-- 3. WALLET BALANCES VIEW
-- ============================================================

CREATE OR REPLACE VIEW wallet_summary AS
SELECT
    u.id                                                           AS user_id,
    COALESCE(SUM(c.amount) FILTER (WHERE c.payment_status = 'completed'), 0) AS total_contributed,
    COALESCE(SUM(p.amount) FILTER (WHERE p.status = 'completed'), 0)         AS total_received,
    COUNT(DISTINCT c.emergency_id)                                 AS campaigns_supported
FROM users u
LEFT JOIN contributions c ON c.contributor_id = u.id
LEFT JOIN payments      p ON p.recipient_id   = u.id
GROUP BY u.id;

-- ============================================================
-- 4. FIX: EMERGENCIES DRIVER ACCESS RLS
-- The original policy uses driver_id (UUID from drivers table)
-- but auth.uid() is the user_id. Fix to join through drivers.
-- ============================================================

DROP POLICY IF EXISTS emergencies_driver_access ON emergencies;

CREATE POLICY emergencies_driver_access ON emergencies
    FOR SELECT USING (
        driver_id = (SELECT id FROM drivers WHERE user_id = auth.uid())
    );

-- ============================================================
-- 5. ADMIN STATS VIEW (replaces hardcoded KPI values in UI)
-- ============================================================

CREATE OR REPLACE VIEW admin_stats AS
SELECT
    (SELECT COUNT(*) FROM emergencies WHERE status NOT IN ('completed','cancelled')) AS active_emergencies,
    (SELECT COUNT(*) FROM users)                                                      AS total_users,
    (SELECT COUNT(*) FROM users WHERE role = 'driver')                               AS total_drivers,
    (SELECT COUNT(*) FROM users WHERE role = 'hospital')                             AS total_hospitals,
    (SELECT COALESCE(SUM(amount),0) FROM contributions WHERE payment_status = 'completed') AS total_funds_raised,
    (SELECT COUNT(*) FROM emergencies WHERE created_at > NOW() - INTERVAL '24 hours') AS emergencies_last_24h,
    (SELECT COUNT(*) FROM emergencies WHERE fraud_flag = TRUE AND status NOT IN ('completed','cancelled')) AS flagged_count,
    (
        SELECT COALESCE(
            EXTRACT(EPOCH FROM AVG(
                (SELECT created_at FROM driver_location_updates dlu
                 WHERE dlu.emergency_id = e.id
                 ORDER BY created_at ASC LIMIT 1)
                - e.created_at
            )) / 60,
            0
        )
        FROM emergencies e
        WHERE e.status IN ('driver_arrived','en_route_hospital','arrived_hospital','in_treatment','completed')
          AND e.created_at > NOW() - INTERVAL '7 days'
    ) AS avg_response_time_minutes;

-- ============================================================
-- 6. CUSTOM JWT AUTH HOOK
-- Embeds user role into JWT claims so RLS policies work.
-- Install this as a "Custom Access Token" hook in:
-- Supabase Dashboard → Auth → Hooks → Custom Access Token
-- ============================================================

-- Create the hook function:
CREATE OR REPLACE FUNCTION public.custom_access_token_hook(event JSONB)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  claims   JSONB;
  user_role TEXT;
BEGIN
  -- Fetch the user's role from the users table
  SELECT role::TEXT INTO user_role
  FROM public.users
  WHERE id = (event->>'user_id')::UUID;

  -- Merge the role into the existing claims
  claims := event->'claims';

  IF user_role IS NOT NULL THEN
    claims := jsonb_set(claims, '{role}', to_jsonb(user_role));
  ELSE
    claims := jsonb_set(claims, '{role}', '"patient"');
  END IF;

  -- Return the modified event
  RETURN jsonb_set(event, '{claims}', claims);
END;
$$;

-- Grant permissions for the hook
GRANT USAGE ON SCHEMA public TO supabase_auth_admin;
GRANT EXECUTE ON FUNCTION public.custom_access_token_hook TO supabase_auth_admin;
REVOKE EXECUTE ON FUNCTION public.custom_access_token_hook FROM authenticated, anon, public;

-- ============================================================
-- 7. ADDITIONAL PERFORMANCE INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_emergencies_fraud
    ON emergencies(fraud_flag, status)
    WHERE fraud_flag = TRUE;

CREATE INDEX IF NOT EXISTS idx_emergencies_funding
    ON emergencies(raised_amount, target_amount, status);

CREATE INDEX IF NOT EXISTS idx_contributions_contributor
    ON contributions(contributor_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_payments_recipient
    ON payments(recipient_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_users_verification
    ON users(verification_status, role);

-- ============================================================
-- 8. UPDATE TRIGGER: emergencies.updated_at on status change
-- (already exists for general updates, this ensures realtime
--  subscriptions fire on status changes for live tracking)
-- ============================================================

-- Re-enable realtime on emergencies table (run in Supabase dashboard if needed)
-- ALTER PUBLICATION supabase_realtime ADD TABLE emergencies;
-- ALTER PUBLICATION supabase_realtime ADD TABLE driver_location_updates;
-- ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- ============================================================
-- 9. GRANT: Allow anon to read hospitals (for dispatch logic)
-- ============================================================

CREATE POLICY hospitals_anon_read ON hospitals
    FOR SELECT USING (verification_status = 'verified');

-- ============================================================
-- 10. ADMIN FULL ACCESS POLICIES (using JWT role claim from hook)
-- ============================================================

-- Now that JWT hook is in place, update admin policies to also allow moderators

DROP POLICY IF EXISTS users_admin_access ON users;
CREATE POLICY users_admin_access ON users
    FOR SELECT USING (
        auth.jwt()->>'role' IN ('admin', 'moderator')
    );

DROP POLICY IF EXISTS emergencies_admin_access ON emergencies;
CREATE POLICY emergencies_admin_access ON emergencies
    FOR ALL USING (
        auth.jwt()->>'role' IN ('admin', 'moderator')
    );

DROP POLICY IF EXISTS audit_logs_admin ON audit_logs;
CREATE POLICY audit_logs_admin ON audit_logs
    FOR SELECT USING (
        auth.jwt()->>'role' IN ('admin', 'moderator')
    );

CREATE POLICY audit_logs_insert ON audit_logs
    FOR INSERT WITH CHECK (TRUE); -- Any authenticated user can write audit events

DROP POLICY IF EXISTS payments_admin ON payments;
CREATE POLICY payments_admin ON payments
    FOR ALL USING (
        auth.jwt()->>'role' IN ('admin', 'moderator')
    );

-- ============================================================
-- DONE
-- After running this migration:
-- 1. Go to Supabase Dashboard → Auth → Hooks
-- 2. Add Custom Access Token hook pointing to: public.custom_access_token_hook
-- 3. Enable Realtime on tables: emergencies, driver_location_updates, notifications
-- ============================================================
