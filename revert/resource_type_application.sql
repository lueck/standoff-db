-- Revert resource_type_application

BEGIN;

REVOKE ALL PRIVILEGES ON standoff.resource_type_application
       FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.resource_type_application;

COMMIT;
