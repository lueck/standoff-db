-- Verify system_prefix

BEGIN;

SELECT (namespace, prefix) FROM standoff.system_prefix WHERE FALSE;

SELECT 1/has_table_privilege('standoffuser', 'standoff.system_prefix', 'SELECT')::integer;
SELECT 1/has_table_privilege('standoffeditor', 'standoff.system_prefix', 'SELECT, INSERT, UPDATE, DELETE')::integer;
SELECT 1/has_table_privilege('standoffadmin', 'standoff.system_prefix', 'SELECT, INSERT, UPDATE, DELETE')::integer;

ROLLBACK;
