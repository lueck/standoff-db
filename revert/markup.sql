-- Revert markup

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.markup
FROM standoffuser, standoffeditor, standoffadmin;

DROP INDEX standoff.markup_document_id_idx;
DROP INDEX standoff.markup_term_id_idx;
DROP INDEX standoff.markup_internalized_idx;

DROP POLICY IF EXISTS assert_well_formed ON standoff.markup;
DROP POLICY IF EXISTS assert_well_formed_null ON standoff.markup;
DROP POLICY IF EXISTS allow_insert_to_editor ON standoff.markup;
DROP POLICY IF EXISTS allow_select_to_editor ON standoff.markup;
DROP POLICY IF EXISTS allow_select_to_owner ON standoff.markup;
DROP POLICY IF EXISTS allow_select_to_group_member ON standoff.markup;
DROP POLICY IF EXISTS allow_select_to_others ON standoff.markup;
DROP POLICY IF EXISTS allow_update_to_editor ON standoff.markup;
DROP POLICY IF EXISTS allow_update_to_owner ON standoff.markup;
DROP POLICY IF EXISTS allow_update_to_group_member ON standoff.markup;
DROP POLICY IF EXISTS allow_update_to_others ON standoff.markup;
DROP POLICY IF EXISTS allow_delete_to_editor ON standoff.markup;
DROP POLICY IF EXISTS allow_delete_to_owner ON standoff.markup;

DROP TABLE IF EXISTS standoff.markup;

COMMIT;
