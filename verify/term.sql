-- Verify term

BEGIN;

SELECT (term_id, local_name, ontology_id, application, created_at, created_by, updated_at, updated_by, gid, privilege) FROM standoff.term WHERE FALSE;


SELECT 1/has_table_privilege('standoffuser', 'standoff.term', 'SELECT, INSERT, UPDATE, DELETE')::integer;
SELECT 1/has_table_privilege('standoffeditor', 'standoff.term', 'SELECT, INSERT, UPDATE, DELETE')::integer;
SELECT 1/has_table_privilege('standoffadmin', 'standoff.term', 'SELECT, INSERT, UPDATE, DELETE')::integer;


--SELECT 1/(has_table_privilege('standoffuser', 'standoff.term', 'INSERT, UPDATE, DELETE')::integer - 1);


SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.term'::regclass
       AND tgname = 'set_meta_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.term'::regclass
       AND tgname = 'set_meta_on_update';


SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.term'::regclass
       AND tgname = 'adjust_privilege_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.term'::regclass
       AND tgname = 'adjust_privilege_on_update';

ROLLBACK;
