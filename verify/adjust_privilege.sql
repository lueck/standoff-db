-- Verify adjust_privilege

BEGIN;

SELECT 'standoff.adjust_privilege'::regproc;

SELECT pg_catalog.has_function_privilege('standoffuser', 'standoff.adjust_privilege()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffeditor', 'standoff.adjust_privilege()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffadmin', 'standoff.adjust_privilege()', 'EXECUTE');


ROLLBACK;
