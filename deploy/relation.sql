-- Deploy relation
-- requires: markup
-- requires: term
-- requires: document
-- requires: arbschema
-- requires: set_meta_on_insert
-- requires: set_meta_on_update
-- requires: adjust_privilege

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.relation (
       id uuid not null DEFAULT uuid_generate_v1(),
       subject uuid not null references standoff.markup,
       predicate int not null references standoff.term,
       object uuid not null references standoff.markup,
       created_at timestamp not null,
       created_by varchar not null,
       updated_at timestamp,
       updated_by varchar,
       gid varchar,
       privilege integer not null DEFAULT 493, -- #o755: rwxr_xr_x
       PRIMARY KEY (id),
       UNIQUE (subject, predicate, object),
       CONSTRAINT relation_term CHECK (standoff.has_term_application(predicate, 'relation'::varchar)));

CREATE INDEX IF NOT EXISTS relation_subject_idx
ON standoff.relation (subject);

CREATE INDEX IF NOT EXISTS relation_predicate_idx
ON standoff.relation (predicate);

CREATE INDEX IF NOT EXISTS relation_object_idx
ON standoff.relation (object);

CREATE INDEX IF NOT EXISTS relation_id_idx
ON standoff.relation (id);


GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE standoff.relation
TO standoffuser, standoffeditor, standoffadmin;


CREATE TRIGGER set_meta_on_insert BEFORE INSERT ON standoff.relation
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

CREATE TRIGGER set_meta_on_update BEFORE UPDATE ON standoff.relation
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_update();

-- 448=#b111000000=#o700: asserts that owner can rwx
CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON standoff.relation
       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(448);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON standoff.relation
       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(448);


-- Row level security:

ALTER TABLE standoff.relation ENABLE ROW LEVEL SECURITY;

-- INSERTION:

CREATE POLICY assert_well_formed ON standoff.relation FOR INSERT TO standoffuser
WITH CHECK (created_by = current_user);

CREATE POLICY assert_well_formed_null ON standoff.relation FOR INSERT TO standoffuser
WITH CHECK (created_by is null); -- if null, then is set to
				 -- current_user by trigger.

-- editor may insert with different created_by
CREATE POLICY allow_insert_to_editor ON standoff.relation FOR INSERT TO standoffeditor
WITH CHECK (true);

-- SELECT:

CREATE POLICY allow_select_to_editor ON standoff.relation FOR SELECT TO standoffeditor
USING (true);

CREATE POLICY allow_select_to_owner ON standoff.relation FOR SELECT TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_select_to_group_member ON standoff.relation FOR SELECT TO standoffuser
USING ((privilege & 32) = 32
        AND pg_has_role(gid, 'MEMBER'));

CREATE POLICY allow_select_to_others ON standoff.relation FOR SELECT TO standoffuser
USING ((privilege & 4) = 4);

-- UPDATE:

CREATE POLICY allow_update_to_editor ON standoff.relation FOR UPDATE TO standoffeditor
USING (true);

CREATE POLICY allow_update_to_owner ON standoff.relation FOR UPDATE TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_update_to_group_member ON standoff.relation FOR UPDATE TO standoffuser
USING ((privilege & 16) = 16
        AND pg_has_role(gid, 'MEMBER'));

CREATE POLICY allow_update_to_others ON standoff.relation FOR UPDATE TO standoffuser
USING (privilege & 2 = 2);

-- DELETE:

CREATE POLICY allow_delete_to_owner ON standoff.relation FOR DELETE TO standoffuser
USING (created_by = current_user);

-- Should we allow deletion to group members?

CREATE POLICY allow_delete_to_editor ON standoff.relation FOR DELETE TO standoffeditor
USING (true);



COMMIT;
