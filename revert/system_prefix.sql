-- Revert system_prefix

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.system_prefix
       FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.system_prefix;

COMMIT;
