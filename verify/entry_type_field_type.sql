-- Verify arb-db:entry_type_field_type on pg

BEGIN;

SELECT (entry_type, field_type, weight)
FROM standoff.entry_type_field_type WHERE TRUE;

ROLLBACK;
