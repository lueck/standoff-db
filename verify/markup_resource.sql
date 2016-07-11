-- Verify markup_resource

BEGIN;

SELECT (id, namespace, local_name, qualified_name, prefix, prefixed_name, definition, created_at, created_by, updated_at, updated_by, gid, privilege)
       FROM standoff.markup_resource WHERE FALSE;


SELECT 1/has_table_privilege('standoffuser', 'standoff.markup_resource', 'SELECT')::integer;
SELECT 1/has_table_privilege('standoffeditor', 'standoff.markup_resource', 'SELECT')::integer;
SELECT 1/has_table_privilege('standoffadmin', 'standoff.markup_resource', 'SELECT')::integer;

ROLLBACK;
