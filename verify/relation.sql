-- Verify relation

BEGIN;

SELECT (relation_id, subject, predicate, object,
       created_at, created_by, updated_at, updated_by,
       gid, privilege)
       FROM standoff.relation
       WHERE TRUE;

SELECT has_table_privilege('standoffuser', 'standoff.relation', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffeditor', 'standoff.relation', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffadmin', 'standoff.relation', 'SELECT, INSERT, UPDATE, DELETE');

ROLLBACK;
