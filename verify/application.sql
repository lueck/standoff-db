-- Verify application

BEGIN;

SELECT (id, description) FROM standoff.application WHERE FALSE;

SELECT has_table_privilege('standoffuser', 'standoff.application', 'SELECT');
SELECT has_table_privilege('standoffeditor', 'standoff.application', 'SELECT');
SELECT has_table_privilege('standoffadmin', 'standoff.application', 'SELECT, INSERT, UPDATE, DELETE');

ROLLBACK;
