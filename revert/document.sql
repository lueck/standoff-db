-- Revert document

BEGIN;

REVOKE ALL PRIVILEGES ON arb.document FROM arbuser, arbeditor, arbadmin;

DROP TRIGGER document_set_meta_on_update ON arb.document;

DROP TRIGGER document_set_meta_on_insert ON arb.document;

DROP TRIGGER adjust_privilege_on_insert ON arb.document;

DROP TRIGGER adjust_privilege_on_update ON arb.document;

DROP TRIGGER set_md5_on_insert ON arb.document;

DROP TRIGGER set_md5_on_update ON arb.document;

DROP FUNCTION arb.set_document_md5();

DROP TABLE arb.document;


COMMIT;
