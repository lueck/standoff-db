-- Deploy markup
-- requires: term
-- requires: ontology
-- requires: document
-- requires: arbschema
-- requires: arbroles
-- requires: set_meta_on_insert
-- requires: set_meta_on_update
-- requires: adjust_privilege

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.markup (
       markup_id uuid not null DEFAULT uuid_generate_v1(),
       document_id int not null references standoff.document,
       term_id int not null references standoff.term,
       internalized boolean not null DEFAULT false,
       created_at timestamp not null,
       created_by varchar not null,
       updated_at timestamp,
       updated_by varchar,
       gid varchar,
       privilege integer not null DEFAULT 493, -- #o755: rwxr_xr_x
       PRIMARY KEY (markup_id),
       CONSTRAINT markup_term CHECK (standoff.has_term_application(term_id, 'markup'::varchar)));

CREATE INDEX IF NOT EXISTS markup_document_id_idx
ON standoff.markup (document_id);

CREATE INDEX IF NOT EXISTS markup_term_id_idx
ON standoff.markup (term_id);

CREATE INDEX IF NOT EXISTS markup_internalized_idx
ON standoff.markup (internalized);

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE standoff.markup
TO standoffuser, standoffeditor, standoffadmin;

CREATE TRIGGER set_meta_on_insert BEFORE INSERT ON standoff.markup
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

CREATE TRIGGER set_meta_on_update BEFORE UPDATE ON standoff.markup
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_update();

-- 448=#b111000000=#o700: asserts that owner can rwx
CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON standoff.markup
       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(448);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON standoff.markup
       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(448);


-- Row level security:

ALTER TABLE standoff.markup ENABLE ROW LEVEL SECURITY;

-- INSERTION:

CREATE POLICY assert_well_formed ON standoff.markup FOR INSERT TO standoffuser
WITH CHECK (created_by = current_user);

CREATE POLICY assert_well_formed_null ON standoff.markup FOR INSERT TO standoffuser
WITH CHECK (created_by is null); -- if null, then is set to
				 -- current_user by trigger.

-- editor may insert with different created_by
CREATE POLICY allow_insert_to_editor ON standoff.markup FOR INSERT TO standoffeditor
WITH CHECK (true);

-- SELECT:

CREATE POLICY allow_select_to_editor ON standoff.markup FOR SELECT TO standoffeditor
USING (true);

CREATE POLICY allow_select_to_owner ON standoff.markup FOR SELECT TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_select_to_group_member ON standoff.markup FOR SELECT TO standoffuser
USING ((privilege & 32) = 32
        AND pg_has_role(gid, 'MEMBER'));

CREATE POLICY allow_select_to_others ON standoff.markup FOR SELECT TO standoffuser
USING ((privilege & 4) = 4);

-- UPDATE:

CREATE POLICY allow_update_to_editor ON standoff.markup FOR UPDATE TO standoffeditor
USING (true);

CREATE POLICY allow_update_to_owner ON standoff.markup FOR UPDATE TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_update_to_group_member ON standoff.markup FOR UPDATE TO standoffuser
USING ((privilege & 16) = 16
        AND pg_has_role(gid, 'MEMBER'));

CREATE POLICY allow_update_to_others ON standoff.markup FOR UPDATE TO standoffuser
USING (privilege & 2 = 2);

-- DELETE:

CREATE POLICY allow_delete_to_owner ON standoff.markup FOR DELETE TO standoffuser
USING (created_by = current_user);

-- Should we allow deletion to group members?

CREATE POLICY allow_delete_to_editor ON standoff.markup FOR DELETE TO standoffeditor
USING (true);


COMMIT;
