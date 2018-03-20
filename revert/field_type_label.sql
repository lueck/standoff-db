-- Revert arb-db:field_type_label from pg

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.field_type_label
FROM standoffadmin, standoffeditor, standoffuser;

DROP TABLE IF EXISTS standoff.field_type_label;

COMMIT;
