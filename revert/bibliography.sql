-- Revert bibliography

BEGIN;

DROP POLICY IF EXISTS allow_select ON standoff.bibliography;
DROP POLICY IF EXISTS assert_well_formed ON standoff.bibliography;
DROP POLICY IF EXISTS assert_well_formed_null ON standoff.bibliography;
DROP POLICY IF EXISTS allow_insert_to_standoffeditor ON standoff.bibliography;
DROP POLICY IF EXISTS allow_update_to_creator ON standoff.bibliography;
DROP POLICY IF EXISTS allow_update_to_group_member ON standoff.bibliography;
DROP POLICY IF EXISTS allow_update_to_others ON standoff.bibliography;
DROP POLICY IF EXISTS allow_update_to_standoffeditor ON standoff.bibliography;
DROP POLICY IF EXISTS allow_delete_to_creator ON standoff.bibliography;
DROP POLICY IF EXISTS allow_delete_to_standoffeditor ON standoff.bibliography;

REVOKE ALL PRIVILEGES ON standoff.bibliography FROM standoffuser, standoffeditor;

DROP TRIGGER bibliography_set_meta_on_update ON standoff.bibliography;

DROP TRIGGER bibliography_set_meta_on_insert ON standoff.bibliography;

DROP TRIGGER adjust_privilege_on_insert ON standoff.bibliography;

DROP TRIGGER adjust_privilege_on_update ON standoff.bibliography;

DROP TABLE standoff.bibliography;

COMMIT;
