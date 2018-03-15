-- Verify arb-db:field_type on pg

BEGIN;

SELECT (field_type_id, field_format_id) FROM standoff.field_type WHERE TRUE;

ROLLBACK;
