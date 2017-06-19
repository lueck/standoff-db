-- Verify markup

BEGIN;

SELECT (document_id,
       markup_id, term_id, internalized,
       created_at, created_by, updated_at, updated_by,
       gid, privilege)
       FROM standoff.markup
       WHERE TRUE;

SELECT has_table_privilege('standoffuser', 'standoff.markup', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffeditor', 'standoff.markup', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffadmin', 'standoff.markup', 'SELECT, INSERT, UPDATE, DELETE');


ROLLBACK;
