-- Verify set_meta_on_update

BEGIN;

SELECT 'standoff.set_meta_on_update'::regproc;

SELECT pg_catalog.has_function_privilege('standoffuser', 'standoff.set_meta_on_update()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffeditor', 'standoff.set_meta_on_update()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffadmin', 'standoff.set_meta_on_update()', 'EXECUTE');

ROLLBACK;
