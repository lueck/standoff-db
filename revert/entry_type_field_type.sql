-- Revert arb-db:entry_type_field_type from pg

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.entry_type_field_type
FROM standoffadmin, standoffeditor, standoffuser;

DROP TABLE IF EXISTS standoff.entry_type_field_type;

COMMIT;
