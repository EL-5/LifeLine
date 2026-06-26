-- Migration: 00004_medical_profiles
-- Description: Creates the medical_profiles table for users to store health information.

CREATE TABLE medical_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blood_group TEXT,
    genotype TEXT,
    allergies TEXT,
    chronic_conditions TEXT,
    current_medications TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE medical_profiles ENABLE ROW LEVEL SECURITY;

-- Policies
-- 1. Users can read their own medical profile
CREATE POLICY "Users can view their own medical profile"
    ON medical_profiles FOR SELECT
    USING (auth.uid() = user_id);

-- 2. Users can insert their own medical profile
CREATE POLICY "Users can insert their own medical profile"
    ON medical_profiles FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 3. Users can update their own medical profile
CREATE POLICY "Users can update their own medical profile"
    ON medical_profiles FOR UPDATE
    USING (auth.uid() = user_id);

-- 4. Hospitals can view medical profiles of patients they are treating (via emergencies)
-- We allow hospitals to read medical_profiles if there is an active emergency linked to that user
CREATE POLICY "Hospitals can view medical profiles of emergency patients"
    ON medical_profiles FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM emergencies e 
            WHERE e.patient_id = medical_profiles.user_id 
              AND e.status != 'completed' 
              AND e.status != 'cancelled'
        )
        AND auth.uid() IN (SELECT id FROM hospitals)
    );

-- We also allow the service role to view profiles for edge functions/webhooks
CREATE POLICY "Service role can do everything"
    ON medical_profiles FOR ALL
    USING (auth.role() = 'service_role');
