-- Verify arb-db:bibliography_field on pg

BEGIN;

SELECT (bibliography_id,
       field_type_id,
       val,
       created_at,
       created_by,
       updated_at,
       updated_by,
       gid,
       privilege
       ) FROM standoff.bibliography_field WHERE TRUE;


ROLLBACK;
