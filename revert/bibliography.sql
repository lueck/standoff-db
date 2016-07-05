-- Revert bibliography

BEGIN;

DROP POLICY IF EXISTS allow_select ON arb.bibliography;
DROP POLICY IF EXISTS assert_well_formed ON arb.bibliography;
DROP POLICY IF EXISTS assert_well_formed_null ON arb.bibliography;
DROP POLICY IF EXISTS allow_insert_to_arbeditor ON arb.bibliography;
DROP POLICY IF EXISTS allow_update_to_creator ON arb.bibliography;
DROP POLICY IF EXISTS allow_update_to_group_member ON arb.bibliography;
DROP POLICY IF EXISTS allow_update_to_others ON arb.bibliography;
DROP POLICY IF EXISTS allow_update_to_arbeditor ON arb.bibliography;
DROP POLICY IF EXISTS allow_delete_to_creator ON arb.bibliography;
DROP POLICY IF EXISTS allow_delete_to_arbeditor ON arb.bibliography;

REVOKE ALL PRIVILEGES ON arb.bibliography FROM arbuser, arbeditor;

DROP TRIGGER bibliography_set_meta_on_update ON arb.bibliography;

DROP TRIGGER bibliography_set_meta_on_insert ON arb.bibliography;

DROP TABLE arb.bibliography;

COMMIT;
