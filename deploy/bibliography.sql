-- Deploy bibliography
-- requires: arbschema
-- requires: arbroles
-- requires: entry_type
-- requires: set_meta_on_insert
-- requires: set_meta_on_update
-- requires: adjust_privilege

BEGIN;

-- Note: 0o775 = 509 same as rwxrwxr_x

CREATE TABLE IF NOT EXISTS standoff.bibliography (
        bibliography_id uuid not null DEFAULT uuid_generate_v1(),
        entry_key varchar(1023) not null,
        entry_type varchar(20) not null references standoff.entry_type,
        created_at timestamp not null,
        created_by varchar not null,
        updated_at timestamp,
        updated_by varchar,
        gid varchar,
        privilege integer not null DEFAULT 509,
        UNIQUE (entry_key),
        PRIMARY KEY (bibliography_id));

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE standoff.bibliography TO standoffuser, standoffeditor;

CREATE TRIGGER bibliography_set_meta_on_insert BEFORE INSERT ON standoff.bibliography
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

CREATE TRIGGER bibliography_set_meta_on_update BEFORE UPDATE ON standoff.bibliography
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_update();

CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON standoff.bibliography
       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(484);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON standoff.bibliography
       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(484);

-- Note: For setting a DEFAULT value for bibliography.gid alter this
-- trigger and pass the gid as an argument to the trigger, like
-- standoff.set_gid('biblio').

-- FIXME:
--CREATE TRIGGER bibliography_set_gid_on_insert BEFORE INSERT ON standoff.bibliography
--       FOR EACH ROW EXECUTE PROCEDURE standoff.set_gid();

-- FIXME:
--CREATE TRIGGER bibliography_adjust_privilege BEFORE INSERT ON standoff.bibliography
--       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege();


ALTER TABLE standoff.bibliography ENABLE ROW LEVEL SECURITY;

-- Note: We do bitwise AND on the integer value of privilege and then
-- test if it equals the bitmask. privilege & 16 = 16 is the same as
-- privilege & (1<<4) = (1<<4), which may be more readable. For
-- performance reasons we replace (1<<4) with the count itself.

CREATE POLICY allow_select ON standoff.bibliography FOR SELECT
USING (true);

CREATE POLICY assert_well_formed ON standoff.bibliography FOR INSERT TO standoffuser
WITH CHECK (created_by = current_user);

CREATE POLICY assert_well_formed_null ON standoff.bibliography FOR INSERT TO standoffuser
WITH CHECK (created_by is null); -- if null, then is set to
				 -- current_user by trigger.

CREATE POLICY allow_insert_to_standoffeditor ON standoff.bibliography FOR INSERT TO standoffeditor
WITH CHECK (true);

CREATE POLICY allow_update_to_creator ON standoff.bibliography FOR UPDATE TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_update_to_group_member ON standoff.bibliography FOR UPDATE TO standoffuser
USING ((privilege & 16) = 16
        AND pg_has_role(gid, 'MEMBER'));

CREATE POLICY allow_update_to_others ON standoff.bibliography FOR UPDATE TO standoffuser
USING (privilege & 2 = 2);

CREATE POLICY allow_update_to_standoffeditor ON standoff.bibliography FOR UPDATE TO standoffeditor
USING (true);

CREATE POLICY allow_delete_to_creator ON standoff.bibliography FOR DELETE TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_delete_to_standoffeditor ON standoff.bibliography FOR DELETE TO standoffeditor
USING (true);


COMMIT;
