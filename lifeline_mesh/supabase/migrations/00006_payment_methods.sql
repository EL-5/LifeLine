-- Migration: 00006_payment_methods
-- Description: Creates the payment_methods table for storing user payment options (Mobile Money, Cards).

CREATE TABLE payment_methods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider_name TEXT NOT NULL, -- e.g., 'MTN Mobile Money', 'Telecel Cash', 'Visa'
    account_number TEXT NOT NULL, -- e.g., '**** 1234' or '024****123'
    icon_name TEXT DEFAULT 'phone_android', -- maps to flutter Icons
    color_code TEXT DEFAULT '#FFC107', -- hex code for UI display color
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure a user only has one default payment method
CREATE UNIQUE INDEX idx_unique_default_payment ON payment_methods (user_id) WHERE is_default = true;

-- Enable Row Level Security
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;

-- Policies
-- 1. Users can read their own payment methods
CREATE POLICY "Users can view their own payment methods"
    ON payment_methods FOR SELECT
    USING (auth.uid() = user_id);

-- 2. Users can insert their own payment methods
CREATE POLICY "Users can insert their own payment methods"
    ON payment_methods FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 3. Users can update their own payment methods
CREATE POLICY "Users can update their own payment methods"
    ON payment_methods FOR UPDATE
    USING (auth.uid() = user_id);

-- 4. Users can delete their own payment methods
CREATE POLICY "Users can delete their own payment methods"
    ON payment_methods FOR DELETE
    USING (auth.uid() = user_id);

-- 5. Service role has full access
CREATE POLICY "Service role can do everything"
    ON payment_methods FOR ALL
    USING (auth.role() = 'service_role');
