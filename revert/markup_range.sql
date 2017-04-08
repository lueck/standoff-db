-- Revert markup

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.markup_range
FROM standoffuser, standoffeditor, standoffadmin;

DROP INDEX standoff.markup_range_text_range_idx;
DROP INDEX standoff.markup_range_source_range_idx;
DROP INDEX standoff.markup_range_document_idx;

DROP POLICY IF EXISTS allow_insert_to_owner ON standoff.markup_range;
DROP POLICY IF EXISTS allow_insert_to_group_member ON standoff.markup_range;
DROP POLICY IF EXISTS allow_insert_to_others ON standoff.markup_range;
DROP POLICY IF EXISTS allow_insert_to_editor ON standoff.markup_range;
DROP POLICY IF EXISTS allow_select_to_editor ON standoff.markup_range;
DROP POLICY IF EXISTS allow_select_to_owner ON standoff.markup_range;
DROP POLICY IF EXISTS allow_select_to_range_owner ON standoff.markup_range;
DROP POLICY IF EXISTS allow_select_to_group_member ON standoff.markup_range;
DROP POLICY IF EXISTS allow_select_to_others ON standoff.markup_range;
DROP POLICY IF EXISTS allow_update_to_editor ON standoff.markup_range;
DROP POLICY IF EXISTS allow_update_to_owner ON standoff.markup_range;
DROP POLICY IF EXISTS allow_update_to_range_owner ON standoff.markup_range;
DROP POLICY IF EXISTS allow_update_to_group_member ON standoff.markup_range;
DROP POLICY IF EXISTS allow_update_to_others ON standoff.markup_range;
DROP POLICY IF EXISTS allow_delete_to_editor ON standoff.markup_range;
DROP POLICY IF EXISTS allow_delete_to_owner ON standoff.markup_range;
DROP POLICY IF EXISTS allow_delete_to_range_owner ON standoff.markup_range;

DROP TABLE IF EXISTS standoff.markup_range;

DROP FUNCTION IF EXISTS standoff.get_markup_document(uuid);
DROP FUNCTION IF EXISTS standoff.get_markup_created_by(uuid);
DROP FUNCTION IF EXISTS standoff.get_markup_privilege(uuid);
DROP FUNCTION IF EXISTS standoff.get_markup_gid(uuid);

COMMIT;
