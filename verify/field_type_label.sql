-- Verify arb-db:field_type_label on pg

BEGIN;

SELECT (field_type,
       language,
       label,
       description
       ) FROM standoff.field_type_label WHERE TRUE;

ROLLBACK;
