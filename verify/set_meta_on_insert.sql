-- Verify set_meta_on_insert

BEGIN;

-- functions are stored on pg_proc system table.
SELECT 'arb.set_meta_on_insert'::regproc;

SELECT pg_catalog.has_function_privilege('arbuser', 'arb.set_meta_on_insert()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('arbeditor', 'arb.set_meta_on_insert()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('arbadmin', 'arb.set_meta_on_insert()', 'EXECUTE');

ROLLBACK;
