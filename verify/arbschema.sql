-- Verify arbschema

BEGIN;

SELECT pg_catalog.has_schema_privilege('standoff', 'usage');

ROLLBACK;
