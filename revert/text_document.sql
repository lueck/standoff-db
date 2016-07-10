-- Revert text_document

BEGIN;

DROP TRIGGER insert_text_document ON standoff.text_document;

DROP FUNCTION standoff.insert_text_document();

REVOKE ALL PRIVILEGES ON standoff.text_document FROM standoffuser, standoffeditor, standoffadmin;

DROP VIEW standoff.text_document;

COMMIT;
