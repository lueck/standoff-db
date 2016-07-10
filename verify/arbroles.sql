-- Verify arbroles

BEGIN;

-- this also verifies the existence of the three roles. 
SELECT has_schema_privilege('standoffuser', 'standoff', 'USAGE');
SELECT has_schema_privilege('standoffeditor', 'standoff', 'USAGE');
SELECT has_schema_privilege('standoffadmin', 'standoff', 'USAGE');

ROLLBACK;
