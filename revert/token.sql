-- Revert token

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.token FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.token;

COMMIT;
