-- Revert arb-db:field_format from pg

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.field_format
FROM standoffadmin, standoffeditor, standoffuser;

DROP TABLE IF EXISTS standoff.field_format;

COMMIT;
