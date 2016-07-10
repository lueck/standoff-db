-- Revert application

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.application FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.application;

COMMIT;
