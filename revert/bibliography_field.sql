-- Revert bibliography_field from pg

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.bibliography_field
FROM standoffadmin, standoffeditor, standoffuser;

DROP TABLE IF EXISTS standoff.bibliography_field;

COMMIT;
