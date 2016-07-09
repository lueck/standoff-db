-- Verify mimetype

BEGIN;

SELECT (id, application) FROM arb.mimetype WHERE FALSE;

SELECT has_table_privilege('arbuser', 'arb.mimetype', 'SELECT');
SELECT has_table_privilege('arbeditor', 'arb.mimetype', 'SELECT');
SELECT has_table_privilege('arbadmin', 'arb.mimetype', 'SELECT, INSERT, UPDATE, DELETE');

ROLLBACK;
