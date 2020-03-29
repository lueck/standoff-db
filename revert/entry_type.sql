-- Revert entry_type

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.entry_type
FROM standoffadmin, standoffeditor, standoffuser;

DROP TABLE standoff.entry_type;

COMMIT;
