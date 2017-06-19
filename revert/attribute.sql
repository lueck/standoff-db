-- Revert attribute

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.attribute
FROM standoffuser, standoffeditor, standoffadmin;

DROP INDEX standoff.attribute_markup_id_idx;
DROP INDEX standoff.attribute_term_id_idx;
DROP INDEX standoff.attribute_attribute_id_idx;

DROP POLICY IF EXISTS assert_well_formed ON standoff.attribute;
DROP POLICY IF EXISTS assert_well_formed_null ON standoff.attribute;
DROP POLICY IF EXISTS allow_insert_to_editor ON standoff.attribute;
DROP POLICY IF EXISTS allow_select_to_editor ON standoff.attribute;
DROP POLICY IF EXISTS allow_select_to_owner ON standoff.attribute;
DROP POLICY IF EXISTS allow_select_to_group_member ON standoff.attribute;
DROP POLICY IF EXISTS allow_select_to_others ON standoff.attribute;
DROP POLICY IF EXISTS allow_update_to_editor ON standoff.attribute;
DROP POLICY IF EXISTS allow_update_to_owner ON standoff.attribute;
DROP POLICY IF EXISTS allow_update_to_group_member ON standoff.attribute;
DROP POLICY IF EXISTS allow_update_to_others ON standoff.attribute;
DROP POLICY IF EXISTS allow_delete_to_editor ON standoff.attribute;
DROP POLICY IF EXISTS allow_delete_to_owner ON standoff.attribute;

DROP TABLE IF EXISTS standoff.attribute;

COMMIT;
