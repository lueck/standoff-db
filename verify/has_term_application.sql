-- Verify has_term_application

BEGIN;

-- functions are stored on pg_proc system table.
SELECT 'standoff.has_term_application'::regproc;

SELECT pg_catalog.has_function_privilege('standoffuser', 'standoff.has_term_application(int, varchar)', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffeditor', 'standoff.has_term_application(int, varchar)', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffadmin', 'standoff.has_term_application(int, varchar)', 'EXECUTE');

ROLLBACK;
