-- Revert markup_resource

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.markup_resource
       FROM standoffuser, standoffeditor, standoffadmin;

DROP VIEW standoff.markup_resource;

COMMIT;
