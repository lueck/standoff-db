-- Verify arb-db:field_type on pg

BEGIN;

SELECT (field_type, field_format) FROM standoff.field_type WHERE TRUE;

ROLLBACK;
