-- Revert document

BEGIN;

DROP POLICY IF EXISTS allow_select ON arb.document;
DROP POLICY IF EXISTS assert_well_formed ON arb.document;
DROP POLICY IF EXISTS assert_well_formed_null ON arb.document;
DROP POLICY IF EXISTS allow_insert_to_arbeditor ON arb.document;
DROP POLICY IF EXISTS allow_update_to_creator ON arb.document;
DROP POLICY IF EXISTS allow_update_to_group_member ON arb.document;
DROP POLICY IF EXISTS allow_update_to_others ON arb.document;
DROP POLICY IF EXISTS allow_update_to_arbeditor ON arb.document;
DROP POLICY IF EXISTS allow_delete_to_creator ON arb.document;
DROP POLICY IF EXISTS allow_delete_to_arbeditor ON arb.document;

REVOKE ALL PRIVILEGES ON arb.document FROM arbuser, arbeditor;

DROP TRIGGER document_set_meta_on_update ON arb.document;

DROP TRIGGER document_set_meta_on_insert ON arb.document;

DROP TRIGGER adjust_privilege_on_insert ON arb.document;

DROP TRIGGER adjust_privilege_on_update ON arb.document;

DROP TRIGGER set_md5_on_insert ON arb.document;

DROP TRIGGER set_md5_on_update ON arb.document;

DROP FUNCTION arb.set_document_md5();

DROP TABLE arb.document;


COMMIT;
