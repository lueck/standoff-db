-- Revert arbroles

BEGIN;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA standoff FROM standoffuser, standoffeditor, standoffadmin;
REVOKE USAGE ON SCHEMA standoff FROM standoffuser, standoffeditor, standoffadmin;

DROP ROLE IF EXISTS standoffuser, standoffeditor, standoffadmin;

COMMIT;
