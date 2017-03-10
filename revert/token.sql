-- Revert token

BEGIN;

DROP TRIGGER delete_on_document_delete ON standoff.document;

DROP FUNCTION standoff.delete_token();

REVOKE ALL PRIVILEGES ON TABLE standoff.token FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.token;

COMMIT;
