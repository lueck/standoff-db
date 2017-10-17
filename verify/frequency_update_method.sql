-- Verify frequency_update_method

BEGIN;

-- functions are stored on pg_proc system table.
SELECT 'standoff.frequency_update_method'::regproc;

SELECT pg_catalog.has_function_privilege('public', 'standoff.frequency_update_method()', 'EXECUTE');

ROLLBACK;
