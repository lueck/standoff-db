-- Deploy markup_range
-- requires: markup
-- requires: document_range
-- requires: set_meta_on_insert
-- requires: set_meta_on_update
-- requires: adjust_privilege

BEGIN;

CREATE OR REPLACE FUNCTION standoff.get_markup_document(mid uuid)
RETURNS int AS $$
	SELECT document_id FROM standoff.markup WHERE markup_id = mid;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION standoff.get_markup_created_by(mid uuid)
RETURNS varchar AS $$
	SELECT created_by FROM standoff.markup WHERE markup_id = mid;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION standoff.get_markup_privilege(mid uuid)
RETURNS integer AS $$
	SELECT privilege FROM standoff.markup WHERE markup_id = mid;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION standoff.get_markup_gid(mid uuid)
RETURNS varchar AS $$
	SELECT gid FROM standoff.markup WHERE markup_id = mid;
$$ LANGUAGE SQL;

CREATE TABLE IF NOT EXISTS standoff.markup_range (
       markup_range_id uuid not null DEFAULT uuid_generate_v1(),
       markup_id uuid not null references standoff.markup,
       created_at timestamp not null,
       created_by varchar not null,
       updated_at timestamp,
       updated_by varchar,
       -- privilege and gid is set on markup
       PRIMARY KEY (markup_range_id),
       UNIQUE (markup_id, text_range),
       UNIQUE (markup_id, source_range),
       -- The column document is redundant. We assert that it is the
       -- same as defined for markup.
       CONSTRAINT markup_range_document CHECK (standoff.get_markup_document(markup_id) = document_id))
       INHERITS (standoff.document_range);


CREATE INDEX IF NOT EXISTS markup_range_text_range_idx
ON standoff.markup_range
USING GIST (text_range);

CREATE INDEX IF NOT EXISTS markup_range_source_range_idx
ON standoff.markup_range
USING GIST (source_range);

CREATE INDEX IF NOT EXISTS markup_range_document_id_idx
ON standoff.markup_range (document_id);

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE standoff.markup_range
TO standoffuser, standoffeditor, standoffadmin;

CREATE TRIGGER set_meta_on_insert BEFORE INSERT ON standoff.markup_range
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

CREATE TRIGGER set_meta_on_update BEFORE UPDATE ON standoff.markup_range
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_update();


-- Row level security:

ALTER TABLE standoff.markup_range ENABLE ROW LEVEL SECURITY;

-- INSERT:

CREATE POLICY allow_insert_to_owner
ON standoff.markup_range FOR INSERT TO standoffuser
WITH CHECK ((created_by = current_user OR created_by is null)
     	    AND standoff.get_markup_created_by(markup_id) = current_user);

-- Insert is allow if x is set on markup.
CREATE POLICY allow_insert_to_group_member
ON standoff.markup_range FOR INSERT TO standoffuser
WITH CHECK ((created_by = current_user OR created_by is null)
     	    AND (standoff.get_markup_privilege(markup_id) & 8) = 8
     	    AND pg_has_role(standoff.get_markup_gid(markup_id), 'MEMBER'));

CREATE POLICY allow_insert_to_others
ON standoff.markup_range FOR INSERT TO standoffuser
WITH CHECK ((created_by = current_user OR created_by is null)
     	    AND (standoff.get_markup_privilege(markup_id) & 1) = 1);

-- editor may insert with different created_by
CREATE POLICY allow_insert_to_editor ON standoff.markup_range FOR INSERT TO standoffeditor
WITH CHECK (true);

-- SELECT:

CREATE POLICY allow_select_to_editor ON standoff.markup_range FOR SELECT TO standoffeditor
USING (true);

CREATE POLICY allow_select_to_owner ON standoff.markup_range FOR SELECT TO standoffuser
USING (standoff.get_markup_created_by(markup_id) = current_user);

-- Allow select to the creator of this range
CREATE POLICY allow_select_to_range_owner ON standoff.markup_range FOR SELECT TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_select_to_group_member ON standoff.markup_range FOR SELECT TO standoffuser
USING ((standoff.get_markup_privilege(markup_id) & 32) = 32
        AND pg_has_role(standoff.get_markup_gid(markup_id), 'MEMBER'));

CREATE POLICY allow_select_to_others ON standoff.markup_range FOR SELECT TO standoffuser
USING ((standoff.get_markup_privilege(markup_id) & 4) = 4);

-- UPDATE:

CREATE POLICY allow_update_to_editor ON standoff.markup_range FOR UPDATE TO standoffeditor
USING (true);

CREATE POLICY allow_update_to_owner ON standoff.markup_range FOR UPDATE TO standoffuser
USING (standoff.get_markup_created_by(markup_id) = current_user);

CREATE POLICY allow_update_to_range_owner ON standoff.markup_range FOR UPDATE TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_update_to_group_member ON standoff.markup_range FOR UPDATE TO standoffuser
USING ((standoff.get_markup_privilege(markup_id) & 16) = 16
        AND pg_has_role(standoff.get_markup_gid(markup_id), 'MEMBER'));

CREATE POLICY allow_update_to_others ON standoff.markup_range FOR UPDATE TO standoffuser
USING (standoff.get_markup_privilege(markup_id) & 2 = 2);

-- DELETE:

CREATE POLICY allow_delete_to_owner ON standoff.markup_range FOR DELETE TO standoffuser
USING (standoff.get_markup_created_by(markup_id) = current_user);

CREATE POLICY allow_delete_to_range_owner ON standoff.markup_range FOR DELETE TO standoffuser
USING (created_by = current_user);

-- Should we allow deletion to group members?

CREATE POLICY allow_delete_to_editor ON standoff.markup_range FOR DELETE TO standoffeditor
USING (true);



COMMIT;
