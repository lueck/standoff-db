-- Verify ontology

BEGIN;

SELECT (ontology_id, iri, version_info, version_iri, namespace_delimiter, prefix, definition, closed, deprecated, created_at, created_by, updated_at, updated_by, gid, privilege) FROM standoff.ontology WHERE FALSE;


SELECT 1/has_table_privilege('standoffuser', 'standoff.ontology', 'SELECT, INSERT, UPDATE')::integer;
SELECT 1/has_table_privilege('standoffeditor', 'standoff.ontology', 'SELECT, INSERT, UPDATE, DELETE')::integer;
SELECT 1/has_table_privilege('standoffadmin', 'standoff.ontology', 'SELECT, INSERT, UPDATE, DELETE')::integer;


SELECT 1/(has_table_privilege('standoffuser', 'standoff.ontology', 'DELETE')::integer - 1);


SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.ontology'::regclass
       AND tgname = 'set_meta_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.ontology'::regclass
       AND tgname = 'set_meta_on_update';


SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.ontology'::regclass
       AND tgname = 'adjust_privilege_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.ontology'::regclass
       AND tgname = 'adjust_privilege_on_update';


ROLLBACK;
