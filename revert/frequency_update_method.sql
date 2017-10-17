-- Revert frequency_update_method

BEGIN;

REVOKE ALL PRIVILEGES ON FUNCTION standoff.frequency_update_method()
FROM PUBLIC;

DROP FUNCTION IF EXISTS standoff.frequency_update_method();

COMMIT;
