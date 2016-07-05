-- Deploy bibliography
-- requires: arbschema
-- requires: arbroles
-- requires: entry_type
-- requires: set_meta_on_insert
-- requires: set_meta_on_update

BEGIN;

-- Note: 0o775 = 509 same as rwxrwxr_x

CREATE TABLE IF NOT EXISTS arb.bibliography (
        id uuid not null DEFAULT uuid_generate_v1(),
        entry_key varchar(1023) not null,
        entry_type varchar(20) not null references arb.entry_type,
        created_at timestamp not null,
        created_by varchar not null,
        updated_at timestamp,
        updated_by varchar,
        gid varchar,
        privilege integer not null DEFAULT 509,
        UNIQUE (entry_key),
        PRIMARY KEY (id));

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE arb.bibliography TO arbuser, arbeditor;

CREATE TRIGGER bibliography_set_meta_on_insert BEFORE INSERT ON arb.bibliography
    FOR EACH ROW EXECUTE PROCEDURE arb.set_meta_on_insert();

CREATE TRIGGER bibliography_set_meta_on_update BEFORE UPDATE ON arb.bibliography
    FOR EACH ROW EXECUTE PROCEDURE arb.set_meta_on_update();

-- Note: For setting a DEFAULT value for bibliography.gid alter this
-- trigger and pass the gid as an argument to the trigger, like
-- arb.set_gid('biblio').

-- FIXME:
--CREATE TRIGGER bibliography_set_gid_on_insert BEFORE INSERT ON arb.bibliography
--       FOR EACH ROW EXECUTE PROCEDURE arb.set_gid();

-- FIXME:
--CREATE TRIGGER bibliography_adjust_privilege BEFORE INSERT ON arb.bibliography
--       FOR EACH ROW EXECUTE PROCEDURE arb.adjust_privilege();


ALTER TABLE arb.bibliography ENABLE ROW LEVEL SECURITY;

-- Note: We do bitwise AND on the integer value of privilege and then
-- test if it equals the bitmask. privilege & 16 = 16 is the same as
-- privilege & (1<<4) = (1<<4), which may be more readable. For
-- performance reasons we replace (1<<4) with the count itself.

CREATE POLICY allow_select ON arb.bibliography FOR SELECT
USING (true);

CREATE POLICY assert_well_formed ON arb.bibliography FOR INSERT TO arbuser
WITH CHECK (created_by = current_user);

CREATE POLICY assert_well_formed_null ON arb.bibliography FOR INSERT TO arbuser
WITH CHECK (created_by is null); -- if null, then is set to
				 -- current_user by trigger.

CREATE POLICY allow_insert_to_arbeditor ON arb.bibliography FOR INSERT TO arbeditor
WITH CHECK (true);

CREATE POLICY allow_update_to_creator ON arb.bibliography FOR UPDATE TO arbuser
USING (created_by = current_user);

CREATE POLICY allow_update_to_group_member ON arb.bibliography FOR UPDATE TO arbuser
USING ((privilege & 16) = 16
        AND pg_has_role(gid, 'MEMBER'));

CREATE POLICY allow_update_to_others ON arb.bibliography FOR UPDATE TO arbuser
USING (privilege & 2 = 2);

CREATE POLICY allow_update_to_arbeditor ON arb.bibliography FOR UPDATE TO arbeditor
USING (true);

CREATE POLICY allow_delete_to_creator ON arb.bibliography FOR DELETE TO arbuser
USING (created_by = current_user);

CREATE POLICY allow_delete_to_arbeditor ON arb.bibliography FOR DELETE TO arbeditor
USING (true);


COMMIT;
