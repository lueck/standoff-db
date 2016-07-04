-- Verify arbroles

BEGIN;

-- this also verifies the existence of the three roles. 
SELECT has_schema_privilege('arbuser', 'arb', 'USAGE');
SELECT has_schema_privilege('arbeditor', 'arb', 'USAGE');
SELECT has_schema_privilege('arbadmin', 'arb', 'USAGE');

ROLLBACK;
