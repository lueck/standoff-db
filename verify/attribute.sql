-- Verify relation

BEGIN;

SELECT (id, markup, term, val,
       created_at, created_by, updated_at, updated_by,
       gid, privilege)
       FROM standoff.attribute
       WHERE TRUE;

SELECT has_table_privilege('standoffuser', 'standoff.attribute', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffeditor', 'standoff.attribute', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffadmin', 'standoff.attribute', 'SELECT, INSERT, UPDATE, DELETE');

ROLLBACK;
