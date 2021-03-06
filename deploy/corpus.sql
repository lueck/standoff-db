-- Deploy corpus
-- requires: arbschema
-- requires: arbroles
-- requires: document
-- requires: adjust_privilege
-- requires: set_meta_on_insert
-- requires: set_meta_on_update
-- requires: extension

BEGIN;

-- Note: The execution bit x means that documents may be added to the
-- corpus by the user, the group or others.

-- We distinguish 3 types of corpus. This enables us to use the same
-- tables for relative frequencies of tokens per document, globally
-- and in a user defined collection of texts. There should be only one
-- global corpus.
CREATE TYPE standoff.corpus_types AS ENUM
       ('global',     -- all documents in DB belong to this corpus 
	'document',   -- a corpus of 1 and only 1 document
	'collection'  -- user defined corpus
	);

CREATE TABLE IF NOT EXISTS standoff.corpus (
       corpus_id serial not null,
       corpus_type standoff.corpus_types not null,
       tokens integer not null default 0,        -- count of tokens in the corpus with duplicates
       tokens_dedupl integer not null default 0, -- count of tokens without duplicates
       title text,
       description text,
       -- meta data.
       created_at timestamp not null,
       created_by varchar not null,
       updated_at timestamp,
       updated_by varchar,
       gid varchar,
       privilege integer not null DEFAULT 508, -- rwxrwxr__, 0o774
       PRIMARY KEY (corpus_id),
       -- only one global corpus
       EXCLUDE (corpus_type WITH =) WHERE (corpus_type = 'global'));

GRANT SELECT, USAGE ON SEQUENCE standoff.corpus_corpus_id_seq TO standoffuser, standoffeditor, standoffadmin;

-- Insert global corpus.
INSERT INTO standoff.corpus
       (corpus_type, title, description, created_at, created_by, gid, privilege) VALUES
       ('global', 'Global corpus',
       'All documents in the database belong to this corpus.',
       current_timestamp,
       current_user,
       current_user,
       292) -- r__r__r__
       ON CONFLICT DO NOTHING;

-- Select is granted on every column.
GRANT SELECT, DELETE ON TABLE standoff.corpus TO standoffuser, standoffeditor;

-- Insert and update is not allowed on columns 'tokens' and
-- 'tokens_dedupl'.
GRANT INSERT (corpus_type, title, description, created_by, created_at, updated_by, updated_at, gid, privilege)
ON TABLE standoff.corpus TO standoffuser, standoffeditor;

GRANT UPDATE (corpus_type, title, description, created_by, created_at, updated_by, updated_at, gid, privilege)
ON TABLE standoff.corpus TO standoffuser, standoffeditor;

CREATE TRIGGER corpus_set_meta_on_insert BEFORE INSERT ON standoff.corpus
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

CREATE TRIGGER corpus_set_meta_on_update BEFORE UPDATE ON standoff.corpus
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_update();


-- Always grant read and write to owner:
CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON standoff.corpus
    FOR EACH ROW
    WHEN (NEW.corpus_type = 'collection'::standoff.corpus_types)
    EXECUTE PROCEDURE standoff.adjust_privilege(384); -- rw_______

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON standoff.corpus
    FOR EACH ROW
    WHEN (NEW.corpus_type = 'collection'::standoff.corpus_types)
    EXECUTE PROCEDURE standoff.adjust_privilege(384); -- rw_______

-- Getter functions for use in security policies. We do not have to
-- grant to anyone.

CREATE FUNCTION standoff.corpus_get_corpus_type(cid integer)
       RETURNS standoff.corpus_types AS $$
       SELECT corpus_type FROM standoff.corpus WHERE corpus_id = cid;
       $$ LANGUAGE SQL;

CREATE FUNCTION standoff.corpus_get_created_by(cid integer)
       RETURNS varchar AS $$
       SELECT created_by FROM standoff.corpus WHERE corpus_id = cid;
       $$ LANGUAGE SQL;

CREATE FUNCTION standoff.corpus_get_privilege(cid integer)
       RETURNS integer AS $$
       SELECT privilege FROM standoff.corpus WHERE corpus_id = cid;
       $$ LANGUAGE SQL;

CREATE FUNCTION standoff.corpus_get_gid(cid integer)
       RETURNS varchar AS $$
       SELECT gid FROM standoff.corpus WHERE corpus_id = cid;
       $$ LANGUAGE SQL;


ALTER TABLE standoff.corpus ENABLE ROW LEVEL SECURITY;

CREATE POLICY allow_select ON standoff.corpus FOR SELECT
USING (true);

-- For INSERT and UPDATE we have to assert that corpus_type is
-- 'collection', what can be done using WITH CHECK.

CREATE POLICY assert_well_formed ON standoff.corpus FOR INSERT TO standoffuser
WITH CHECK (corpus_type = 'collection' AND created_by = current_user);

-- if null, then is set to current_user by trigger.
CREATE POLICY assert_well_formed_null ON standoff.corpus FOR INSERT TO standoffuser
WITH CHECK (corpus_type = 'collection' AND created_by is null);

CREATE POLICY allow_insert_to_standoffeditor ON standoff.corpus FOR INSERT TO standoffeditor
WITH CHECK (corpus_type = 'collection');

CREATE POLICY allow_update_to_creator ON standoff.corpus FOR UPDATE TO standoffuser
USING (created_by = current_user)
WITH CHECK (corpus_type = 'collection');

CREATE POLICY allow_update_to_group_member ON standoff.corpus FOR UPDATE TO standoffuser
USING ((privilege & 16) = 16
        AND pg_has_role(gid, 'MEMBER'))
WITH CHECK (corpus_type = 'collection');

CREATE POLICY allow_update_to_others ON standoff.corpus FOR UPDATE TO standoffuser
USING (privilege & 2 = 2)
WITH CHECK (corpus_type = 'collection');

CREATE POLICY allow_update_to_standoffeditor ON standoff.corpus FOR UPDATE TO standoffeditor
WITH CHECK (corpus_type = 'collection');

CREATE POLICY allow_delete_to_creator ON standoff.corpus FOR DELETE TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_delete_to_standoffeditor ON standoff.corpus FOR DELETE TO standoffeditor
USING (true);

COMMIT;
