-- Revert document

BEGIN;

DROP POLICY IF EXISTS allow_select ON standoff.document;
DROP POLICY IF EXISTS assert_well_formed ON standoff.document;
DROP POLICY IF EXISTS assert_well_formed_null ON standoff.document;
DROP POLICY IF EXISTS allow_insert_to_standoffeditor ON standoff.document;
DROP POLICY IF EXISTS allow_update_to_creator ON standoff.document;
DROP POLICY IF EXISTS allow_update_to_group_member ON standoff.document;
DROP POLICY IF EXISTS allow_update_to_others ON standoff.document;
DROP POLICY IF EXISTS allow_update_to_standoffeditor ON standoff.document;
DROP POLICY IF EXISTS allow_delete_to_creator ON standoff.document;
DROP POLICY IF EXISTS allow_delete_to_standoffeditor ON standoff.document;

REVOKE ALL PRIVILEGES ON standoff.document FROM standoffuser, standoffeditor, standoffadmin;

REVOKE ALL PRIVILEGES ON standoff.document_document_id_seq FROM standoffuser, standoffeditor, standoffadmin;

DROP TRIGGER document_set_meta_on_update ON standoff.document;

DROP TRIGGER document_set_meta_on_insert ON standoff.document;

DROP TRIGGER adjust_privilege_on_insert ON standoff.document;

DROP TRIGGER adjust_privilege_on_update ON standoff.document;

DROP TRIGGER set_md5_on_insert ON standoff.document;

DROP TRIGGER set_md5_on_update ON standoff.document;

DROP FUNCTION standoff.set_document_md5();

DROP TABLE standoff.document;


COMMIT;
