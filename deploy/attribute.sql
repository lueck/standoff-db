-- Deploy attribute
-- requires: markup
-- requires: term
-- requires: arbschema
-- requires: set_meta_on_insert
-- requires: set_meta_on_update
-- requires: adjust_privilege

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.attribute (
       attribute_id uuid not null DEFAULT uuid_generate_v1(),
       markup_id uuid not null references standoff.markup,
       term_id int not null references standoff.term,
       val text not null,
       created_at timestamp not null,
       created_by varchar not null,
       updated_at timestamp,
       updated_by varchar,
       gid varchar,
       privilege integer not null DEFAULT 493, -- #o755: rwxr_xr_x
       PRIMARY KEY (attribute_id),
       CONSTRAINT attribute_key_term CHECK (standoff.has_term_application(term_id, 'attribute'::varchar)));

CREATE INDEX IF NOT EXISTS attribute_markup_id_idx
ON standoff.attribute (markup_id);

CREATE INDEX IF NOT EXISTS attribute_term_id_idx
ON standoff.attribute (term_id);

CREATE INDEX IF NOT EXISTS attribute_attribute_id_idx
ON standoff.attribute (attribute_id);


GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE standoff.attribute
TO standoffuser, standoffeditor, standoffadmin;


CREATE TRIGGER set_meta_on_insert BEFORE INSERT ON standoff.attribute
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

CREATE TRIGGER set_meta_on_update BEFORE UPDATE ON standoff.attribute
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_update();

-- 448=#b111000000=#o700: asserts that owner can rwx
CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON standoff.attribute
       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(448);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON standoff.attribute
       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(448);


-- Row level security:

ALTER TABLE standoff.attribute ENABLE ROW LEVEL SECURITY;

-- INSERTION:

CREATE POLICY assert_well_formed ON standoff.attribute FOR INSERT TO standoffuser
WITH CHECK (created_by = current_user);

CREATE POLICY assert_well_formed_null ON standoff.attribute FOR INSERT TO standoffuser
WITH CHECK (created_by is null); -- if null, then is set to
				 -- current_user by trigger.

-- editor may insert with different created_by
CREATE POLICY allow_insert_to_editor ON standoff.attribute FOR INSERT TO standoffeditor
WITH CHECK (true);

-- SELECT:

CREATE POLICY allow_select_to_editor ON standoff.attribute FOR SELECT TO standoffeditor
USING (true);

CREATE POLICY allow_select_to_owner ON standoff.attribute FOR SELECT TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_select_to_group_member ON standoff.attribute FOR SELECT TO standoffuser
USING ((privilege & 32) = 32
        AND pg_has_role(gid, 'MEMBER'));

CREATE POLICY allow_select_to_others ON standoff.attribute FOR SELECT TO standoffuser
USING ((privilege & 4) = 4);

-- UPDATE:

CREATE POLICY allow_update_to_editor ON standoff.attribute FOR UPDATE TO standoffeditor
USING (true);

CREATE POLICY allow_update_to_owner ON standoff.attribute FOR UPDATE TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_update_to_group_member ON standoff.attribute FOR UPDATE TO standoffuser
USING ((privilege & 16) = 16
        AND pg_has_role(gid, 'MEMBER'));

CREATE POLICY allow_update_to_others ON standoff.attribute FOR UPDATE TO standoffuser
USING (privilege & 2 = 2);

-- DELETE:

CREATE POLICY allow_delete_to_owner ON standoff.attribute FOR DELETE TO standoffuser
USING (created_by = current_user);

-- Should we allow deletion to group members?

CREATE POLICY allow_delete_to_editor ON standoff.attribute FOR DELETE TO standoffeditor
USING (true);



COMMIT;
