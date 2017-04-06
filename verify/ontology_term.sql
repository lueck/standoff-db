-- Verify ontology_term

BEGIN;

SELECT (id, iri, version_iri, local_name, namespace_delimiter, qualified_name, prefix, prefixed_name, created_at, created_by, updated_at, updated_by, gid, privilege)
       FROM standoff.ontology_term WHERE FALSE;


SELECT 1/has_table_privilege('standoffuser', 'standoff.ontology_term', 'SELECT')::integer;
SELECT 1/has_table_privilege('standoffeditor', 'standoff.ontology_term', 'SELECT')::integer;
SELECT 1/has_table_privilege('standoffadmin', 'standoff.ontology_term', 'SELECT')::integer;

ROLLBACK;
