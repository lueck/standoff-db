-- Verify ontology_resource

BEGIN;

SELECT (id, local_name, ontology, application, created_at, created_by, updated_at, updated_by, gid, privilege) FROM standoff.ontology_resource WHERE FALSE;


SELECT 1/has_table_privilege('standoffuser', 'standoff.ontology_resource', 'SELECT')::integer;
SELECT 1/has_table_privilege('standoffeditor', 'standoff.ontology_resource', 'SELECT, INSERT, UPDATE, DELETE')::integer;
SELECT 1/has_table_privilege('standoffadmin', 'standoff.ontology_resource', 'SELECT, INSERT, UPDATE, DELETE')::integer;


SELECT 1/(has_table_privilege('standoffuser', 'standoff.ontology_resource', 'INSERT, UPDATE, DELETE')::integer - 1);


SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.ontology_resource'::regclass
       AND tgname = 'set_meta_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.ontology_resource'::regclass
       AND tgname = 'set_meta_on_update';


SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.ontology_resource'::regclass
       AND tgname = 'adjust_privilege_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.ontology_resource'::regclass
       AND tgname = 'adjust_privilege_on_update';

ROLLBACK;
