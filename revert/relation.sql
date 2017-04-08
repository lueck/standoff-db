-- Revert relation

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.relation
FROM standoffuser, standoffeditor, standoffadmin;

DROP INDEX standoff.relation_subject_idx;
DROP INDEX standoff.relation_predicate_idx;
DROP INDEX standoff.relation_object_idx;
DROP INDEX standoff.relation_id_idx;

DROP POLICY IF EXISTS assert_well_formed ON standoff.relation;
DROP POLICY IF EXISTS assert_well_formed_null ON standoff.relation;
DROP POLICY IF EXISTS allow_insert_to_editor ON standoff.relation;
DROP POLICY IF EXISTS allow_select_to_editor ON standoff.relation;
DROP POLICY IF EXISTS allow_select_to_owner ON standoff.relation;
DROP POLICY IF EXISTS allow_select_to_group_member ON standoff.relation;
DROP POLICY IF EXISTS allow_select_to_others ON standoff.relation;
DROP POLICY IF EXISTS allow_update_to_editor ON standoff.relation;
DROP POLICY IF EXISTS allow_update_to_owner ON standoff.relation;
DROP POLICY IF EXISTS allow_update_to_group_member ON standoff.relation;
DROP POLICY IF EXISTS allow_update_to_others ON standoff.relation;
DROP POLICY IF EXISTS allow_delete_to_editor ON standoff.relation;
DROP POLICY IF EXISTS allow_delete_to_owner ON standoff.relation;

DROP TABLE IF EXISTS standoff.relation;

COMMIT;
