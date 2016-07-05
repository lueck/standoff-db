-- Verify adjust_privilege

BEGIN;

SELECT 'arb.adjust_privilege'::regproc;

SELECT pg_catalog.has_function_privilege('arbuser', 'arb.adjust_privilege()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('arbeditor', 'arb.adjust_privilege()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('arbadmin', 'arb.adjust_privilege()', 'EXECUTE');


ROLLBACK;
