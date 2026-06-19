-- Run this script in the Supabase SQL Editor to completely clear out the LifeLine database.
-- It uses CASCADE to automatically remove any dependent foreign keys, indexes, and triggers.

-- 1. Drop all tables
DROP TABLE IF EXISTS trust_events CASCADE;
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS contributions CASCADE;
DROP TABLE IF EXISTS family_connections CASCADE;
DROP TABLE IF EXISTS emergencies CASCADE;
DROP TABLE IF EXISTS drivers CASCADE;
DROP TABLE IF EXISTS hospitals CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 2. Drop all custom functions
DROP FUNCTION IF EXISTS update_updated_at CASCADE;
DROP FUNCTION IF EXISTS update_raised_amount CASCADE;

-- 3. Drop all custom ENUM types
DROP TYPE IF EXISTS trust_event_status CASCADE;
DROP TYPE IF EXISTS validation_type CASCADE;
DROP TYPE IF EXISTS payment_type CASCADE;
DROP TYPE IF EXISTS verification_status CASCADE;
DROP TYPE IF EXISTS payment_status CASCADE;
DROP TYPE IF EXISTS payment_method CASCADE;
DROP TYPE IF EXISTS connection_status CASCADE;
DROP TYPE IF EXISTS relationship_type CASCADE;
DROP TYPE IF EXISTS emergency_status CASCADE;
DROP TYPE IF EXISTS severity_level CASCADE;
DROP TYPE IF EXISTS emergency_category CASCADE;
DROP TYPE IF EXISTS user_role CASCADE;

-- Database is now completely empty and ready for your new script!
