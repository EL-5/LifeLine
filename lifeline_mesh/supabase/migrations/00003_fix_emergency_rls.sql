-- Drop the old overly-restrictive policies
DROP POLICY IF EXISTS emergencies_driver_access ON emergencies;
DROP POLICY IF EXISTS emergencies_hospital_access ON emergencies;

-- Create new policies that allow visibility for new emergencies
-- Drivers: Can see emergencies assigned to them OR any emergency that is currently pending/dispatched
CREATE POLICY emergencies_driver_access ON emergencies
    FOR SELECT USING (
        driver_id = auth.uid() OR status IN ('pending', 'dispatched')
    );

-- Hospitals: Can see emergencies assigned to them OR any emergency that isn't finished/cancelled
CREATE POLICY emergencies_hospital_access ON emergencies
    FOR SELECT USING (
        hospital_id = auth.uid() OR status NOT IN ('completed', 'cancelled')
    );
