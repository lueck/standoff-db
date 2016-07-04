-- Verify set_meta_on_update

BEGIN;

SELECT 'arb.set_meta_on_update'::regproc;

SELECT pg_catalog.has_function_privilege('arbuser', 'arb.set_meta_on_update()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('arbeditor', 'arb.set_meta_on_update()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('arbadmin', 'arb.set_meta_on_update()', 'EXECUTE');

ROLLBACK;
