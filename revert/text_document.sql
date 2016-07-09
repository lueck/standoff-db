-- Revert text_document

BEGIN;

DROP TRIGGER insert_text_document ON arb.text_document;

DROP FUNCTION arb.insert_text_document();

REVOKE ALL PRIVILEGES ON arb.text_document FROM arbuser, arbeditor, arbadmin;

DROP VIEW arb.text_document;

COMMIT;
