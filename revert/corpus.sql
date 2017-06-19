-- Revert corpus

BEGIN;

DROP POLICY IF EXISTS allow_select ON standoff.corpus;
DROP POLICY IF EXISTS assert_well_formed ON standoff.corpus;
DROP POLICY IF EXISTS assert_well_formed_null ON standoff.corpus;
DROP POLICY IF EXISTS allow_insert_to_standoffeditor ON standoff.corpus;
DROP POLICY IF EXISTS allow_update_to_creator ON standoff.corpus;
DROP POLICY IF EXISTS allow_update_to_group_member ON standoff.corpus;
DROP POLICY IF EXISTS allow_update_to_others ON standoff.corpus;
DROP POLICY IF EXISTS allow_update_to_standoffeditor ON standoff.corpus;
DROP POLICY IF EXISTS allow_delete_to_creator ON standoff.corpus;
DROP POLICY IF EXISTS allow_delete_to_standoffeditor ON standoff.corpus;


DROP FUNCTION standoff.corpus_get_corpus_type(integer);
DROP FUNCTION standoff.corpus_get_created_by(integer);
DROP FUNCTION standoff.corpus_get_privilege(integer);
DROP FUNCTION standoff.corpus_get_gid(integer);


REVOKE ALL PRIVILEGES ON standoff.corpus FROM standoffuser, standoffeditor, standoffadmin;

REVOKE ALL PRIVILEGES ON standoff.corpus_corpus_id_seq FROM standoffuser, standoffeditor, standoffadmin;

DROP TRIGGER corpus_set_meta_on_update ON standoff.corpus;

DROP TRIGGER corpus_set_meta_on_insert ON standoff.corpus;

DROP TABLE standoff.corpus;

DROP TYPE standoff.corpus_types;

COMMIT;
