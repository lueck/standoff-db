-- Verify mimetype

BEGIN;

SELECT (id, application) FROM standoff.mimetype WHERE FALSE;

SELECT has_table_privilege('standoffuser', 'standoff.mimetype', 'SELECT');
SELECT has_table_privilege('standoffeditor', 'standoff.mimetype', 'SELECT');
SELECT has_table_privilege('standoffadmin', 'standoff.mimetype', 'SELECT, INSERT, UPDATE, DELETE');

ROLLBACK;
