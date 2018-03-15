-- Revert arb-db:field_type from pg

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.field_type
FROM standoffadmin, standoffeditor, standoffuser;

DROP TABLE IF EXISTS standoff.field_type;

COMMIT;
