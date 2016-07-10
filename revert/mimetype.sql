-- Revert mimetype

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.mimetype FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.mimetype;

COMMIT;
