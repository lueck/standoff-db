-- Deploy markup_range
-- requires: markup
-- requires: document_range
-- requires: set_meta_on_insert
-- requires: set_meta_on_update
-- requires: adjust_privilege

BEGIN;

CREATE OR REPLACE FUNCTION standoff.get_markup_document(markupId uuid)
RETURNS int AS $$
	SELECT document FROM standoff.markup WHERE id = markupId;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION standoff.get_markup_created_by(markupId uuid)
RETURNS varchar AS $$
	SELECT created_by FROM standoff.markup WHERE id = markupId;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION standoff.get_markup_privilege(markupId uuid)
RETURNS integer AS $$
	SELECT privilege FROM standoff.markup WHERE id = markupId;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION standoff.get_markup_gid(markupId uuid)
RETURNS varchar AS $$
	SELECT gid FROM standoff.markup WHERE id = markupId;
$$ LANGUAGE SQL;

CREATE TABLE IF NOT EXISTS standoff.markup_range (
       id uuid not null DEFAULT uuid_generate_v1(),
       markup uuid not null references standoff.markup,
       created_at timestamp not null,
       created_by varchar not null,
       updated_at timestamp,
       updated_by varchar,
       -- privilege and gid is set on markup
       PRIMARY KEY (id),
       UNIQUE (markup, text_range),
       UNIQUE (markup, source_range),
       -- The column document is redundant. We assert that it is the
       -- same as defined for markup.
       CONSTRAINT markup_range_document CHECK (standoff.get_markup_document(markup) = document))
       INHERITS (standoff.document_range);


CREATE INDEX IF NOT EXISTS markup_range_text_range_idx
ON standoff.markup_range
USING GIST (text_range);

CREATE INDEX IF NOT EXISTS markup_range_source_range_idx
ON standoff.markup_range
USING GIST (source_range);

CREATE INDEX IF NOT EXISTS markup_range_document_idx
ON standoff.markup_range (document);

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
     	    AND standoff.get_markup_created_by(markup) = current_user);

-- Insert is allow if x is set on markup.
CREATE POLICY allow_insert_to_group_member
ON standoff.markup_range FOR INSERT TO standoffuser
WITH CHECK ((created_by = current_user OR created_by is null)
     	    AND (standoff.get_markup_privilege(markup) & 8) = 8
     	    AND pg_has_role(standoff.get_markup_gid(markup), 'MEMBER'));

CREATE POLICY allow_insert_to_others
ON standoff.markup_range FOR INSERT TO standoffuser
WITH CHECK ((created_by = current_user OR created_by is null)
     	    AND (standoff.get_markup_privilege(markup) & 1) = 1);

-- editor may insert with different created_by
CREATE POLICY allow_insert_to_editor ON standoff.markup_range FOR INSERT TO standoffeditor
WITH CHECK (true);

-- SELECT:

CREATE POLICY allow_select_to_editor ON standoff.markup_range FOR SELECT TO standoffeditor
USING (true);

CREATE POLICY allow_select_to_owner ON standoff.markup_range FOR SELECT TO standoffuser
USING (standoff.get_markup_created_by(markup) = current_user);

-- Allow select to the creator of this range
CREATE POLICY allow_select_to_range_owner ON standoff.markup_range FOR SELECT TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_select_to_group_member ON standoff.markup_range FOR SELECT TO standoffuser
USING ((standoff.get_markup_privilege(markup) & 32) = 32
        AND pg_has_role(standoff.get_markup_gid(markup), 'MEMBER'));

CREATE POLICY allow_select_to_others ON standoff.markup_range FOR SELECT TO standoffuser
USING ((standoff.get_markup_privilege(markup) & 4) = 4);

-- UPDATE:

CREATE POLICY allow_update_to_editor ON standoff.markup_range FOR UPDATE TO standoffeditor
USING (true);

CREATE POLICY allow_update_to_owner ON standoff.markup_range FOR UPDATE TO standoffuser
USING (standoff.get_markup_created_by(markup) = current_user);

CREATE POLICY allow_update_to_range_owner ON standoff.markup_range FOR UPDATE TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_update_to_group_member ON standoff.markup_range FOR UPDATE TO standoffuser
USING ((standoff.get_markup_privilege(markup) & 16) = 16
        AND pg_has_role(standoff.get_markup_gid(markup), 'MEMBER'));

CREATE POLICY allow_update_to_others ON standoff.markup_range FOR UPDATE TO standoffuser
USING (standoff.get_markup_privilege(markup) & 2 = 2);

-- DELETE:

CREATE POLICY allow_delete_to_owner ON standoff.markup_range FOR DELETE TO standoffuser
USING (standoff.get_markup_created_by(markup) = current_user);

CREATE POLICY allow_delete_to_range_owner ON standoff.markup_range FOR DELETE TO standoffuser
USING (created_by = current_user);

-- Should we allow deletion to group members?

CREATE POLICY allow_delete_to_editor ON standoff.markup_range FOR DELETE TO standoffeditor
USING (true);



COMMIT;
