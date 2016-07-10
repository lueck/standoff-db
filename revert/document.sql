-- Revert document

BEGIN;

REVOKE ALL PRIVILEGES ON standoff.document FROM standoffuser, standoffeditor, standoffadmin;

DROP TRIGGER document_set_meta_on_update ON standoff.document;

DROP TRIGGER document_set_meta_on_insert ON standoff.document;

DROP TRIGGER adjust_privilege_on_insert ON standoff.document;

DROP TRIGGER adjust_privilege_on_update ON standoff.document;

DROP TRIGGER set_md5_on_insert ON standoff.document;

DROP TRIGGER set_md5_on_update ON standoff.document;

DROP FUNCTION standoff.set_document_md5();

DROP TABLE standoff.document;


COMMIT;
