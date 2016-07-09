-- Verify application

BEGIN;

SELECT (id, description) FROM arb.application WHERE FALSE;

SELECT has_table_privilege('arbuser', 'arb.application', 'SELECT');
SELECT has_table_privilege('arbeditor', 'arb.application', 'SELECT');
SELECT has_table_privilege('arbadmin', 'arb.application', 'SELECT, INSERT, UPDATE, DELETE');

ROLLBACK;
