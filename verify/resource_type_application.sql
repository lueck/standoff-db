-- Verify resource_type_application

BEGIN;

SELECT (qualified_name, application)
       FROM standoff.resource_type_application WHERE FALSE;

SELECT 1/has_table_privilege('standoffuser', 'standoff.resource_type_application', 'SELECT')::integer;
SELECT 1/has_table_privilege('standoffeditor', 'standoff.resource_type_application', 'SELECT, INSERT, UPDATE, DELETE')::integer;
SELECT 1/has_table_privilege('standoffadmin', 'standoff.resource_type_application', 'SELECT, INSERT, UPDATE, DELETE')::integer;


SELECT 1/(has_table_privilege('standoffuser', 'standoff.resource_type_application', 'INSERT, UPDATE, DELETE')::integer - 1);

ROLLBACK;
