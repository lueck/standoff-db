-- Verify set_meta_on_insert

BEGIN;

-- functions are stored on pg_proc system table.
SELECT 'standoff.set_meta_on_insert'::regproc;

SELECT pg_catalog.has_function_privilege('standoffuser', 'standoff.set_meta_on_insert()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffeditor', 'standoff.set_meta_on_insert()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffadmin', 'standoff.set_meta_on_insert()', 'EXECUTE');

ROLLBACK;
