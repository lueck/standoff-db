-- Verify arb-db:field_format on pg

BEGIN;

SELECT (field_format_id, regexp)
FROM standoff.field_format WHERE TRUE;

ROLLBACK;
