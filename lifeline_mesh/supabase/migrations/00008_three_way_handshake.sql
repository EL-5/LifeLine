-- Migration: 00008_three_way_handshake.sql
-- Description: Adds tracking for the 3-way handshake and an automated webhook trigger

-- 1. Add confirmation flags to emergencies
ALTER TABLE emergencies
ADD COLUMN IF NOT EXISTS patient_confirmed_pickup BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS patient_confirmed_dropoff BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS hospital_confirmed_arrival BOOLEAN DEFAULT false;

-- 2. Create pg_net extension for webhooks if not exists
CREATE EXTENSION IF NOT EXISTS pg_net;

-- 3. Create the webhook trigger function
CREATE OR REPLACE FUNCTION handle_three_way_handshake()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if all three confirmations are true, and it wasn't already true
    IF NEW.patient_confirmed_pickup = true AND
       NEW.patient_confirmed_dropoff = true AND
       NEW.hospital_confirmed_arrival = true AND
       NEW.status != 'completed'
    THEN
        -- Automatically mark status as completed
        NEW.status := 'completed';
        NEW.completed_at := NOW();
        
        -- Invoke the release-payment Edge Function via pg_net HTTP POST
        PERFORM net.http_post(
            url := 'https://gkhlrqlgmkreubsruzej.supabase.co/functions/v1/release-payment',
            headers := '{"Content-Type": "application/json", "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdraGxycWxnbWtyZXVic3J1emVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODExMjc5MTgsImV4cCI6MjA5NjcwMzkxOH0.YHYs6yD9gPEOrA7FwY36N26M3jPotrn4f70bh5FnDiA"}'::jsonb,
            body := json_build_object(
                'emergency_id', NEW.id,
                'payment_type', 'driver_payout',
                'recipient_id', NEW.driver_id,
                'amount', NEW.target_amount
            )::jsonb
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Attach the trigger
DROP TRIGGER IF EXISTS trigger_three_way_handshake ON emergencies;
CREATE TRIGGER trigger_three_way_handshake
    BEFORE UPDATE ON emergencies
    FOR EACH ROW
    EXECUTE FUNCTION handle_three_way_handshake();
