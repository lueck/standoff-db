-- Deploy document
-- requires: bibliography
-- requires: arbschema
-- requires: arbroles
-- requires: adjust_privilege
-- requires: set_meta_on_insert
-- requires: set_meta_on_update
-- requires: extension

-- Note: privilege value 365 is #o555, r_xr_xr_x. Update is not
-- allowed to anyone until there's a mechanism for updating the offset
-- pointers of markup ranges.

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.document (
	id serial not null,
	reference uuid not null references standoff.bibliography,
	source_md5 uuid not null,
	source_base64 text not null,
	source_uri varchar,
	source_charset varchar,
	mimetype varchar not null references standoff.mimetype,
	description text,
	plaintext text, -- plain text like text layer in TCF
	-- for text types
	charset varchar, -- character set of source
	text_offset integer, -- FIXME: needed?
	xml_offset_xpointer varchar, -- FIXME: needed?
	-- meta data for all types of documents
        created_at timestamp not null,
        created_by varchar not null,
        updated_at timestamp,
        updated_by varchar,
        gid varchar,
        privilege integer not null DEFAULT 365,
	PRIMARY KEY (id),
	UNIQUE (source_md5));


GRANT SELECT, INSERT, DELETE ON TABLE standoff.document TO standoffuser, standoffeditor, standoffadmin;

GRANT SELECT, USAGE ON SEQUENCE standoff.document_id_seq TO standoffuser, standoffeditor, standoffadmin;

-- UPDATE on source_base64 is not allowed to anybody, until there's a mechanism to
-- adjust the offset pointers of markup ranges.
GRANT UPDATE (reference, source_uri, source_charset, mimetype, description, updated_at, updated_by) ON TABLE standoff.document TO standoffeditor, standoffadmin;


CREATE TRIGGER document_set_meta_on_insert BEFORE INSERT ON standoff.document
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

CREATE TRIGGER document_set_meta_on_update BEFORE UPDATE ON standoff.document
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_update();


CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON standoff.document
       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(365);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON standoff.document
       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(365);


-- Note: For setting a DEFAULT value for document.gid alter this
-- trigger and pass the gid as an argument to the trigger, like
-- standoff.set_gid('biblio').

-- FIXME:
--CREATE TRIGGER document_set_gid_on_insert BEFORE INSERT ON standoff.document
--       FOR EACH ROW EXECUTE PROCEDURE standoff.set_gid();

-- FIXME:
--CREATE TRIGGER document_adjust_privilege BEFORE INSERT ON standoff.document
--       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege();


CREATE FUNCTION standoff.set_document_md5() RETURNS TRIGGER AS $$
       BEGIN
	NEW.source_md5 = coalesce(md5(decode(NEW.source_base64, 'base64'))::uuid, OLD.source_base64::uuid);
	RETURN NEW;
	END; $$ LANGUAGE 'plpgsql';

CREATE TRIGGER set_md5_on_insert BEFORE INSERT ON standoff.document
       FOR EACH ROW EXECUTE PROCEDURE standoff.set_document_md5();

CREATE TRIGGER set_md5_on_update BEFORE UPDATE ON standoff.document
       FOR EACH ROW EXECUTE PROCEDURE standoff.set_document_md5();


ALTER TABLE standoff.document ENABLE ROW LEVEL SECURITY;

-- Note: We do bitwise AND on the integer value of privilege and then
-- test if it equals the bitmask. privilege & 16 = 16 is the same as
-- privilege & (1<<4) = (1<<4), which may be more readable. For
-- performance reasons we replace (1<<4) with the count itself.

CREATE POLICY allow_select ON standoff.document FOR SELECT
USING (true);

CREATE POLICY assert_well_formed ON standoff.document FOR INSERT TO standoffuser
WITH CHECK (created_by = current_user);

CREATE POLICY assert_well_formed_null ON standoff.document FOR INSERT TO standoffuser
WITH CHECK (created_by is null); -- if null, then is set to
				 -- current_user by trigger.

CREATE POLICY allow_insert_to_standoffeditor ON standoff.document FOR INSERT TO standoffeditor
WITH CHECK (true);

CREATE POLICY allow_update_to_creator ON standoff.document FOR UPDATE TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_update_to_group_member ON standoff.document FOR UPDATE TO standoffuser
USING ((privilege & 16) = 16
        AND pg_has_role(gid, 'MEMBER'));

CREATE POLICY allow_update_to_others ON standoff.document FOR UPDATE TO standoffuser
USING (privilege & 2 = 2);

CREATE POLICY allow_update_to_standoffeditor ON standoff.document FOR UPDATE TO standoffeditor
USING (true);

CREATE POLICY allow_delete_to_creator ON standoff.document FOR DELETE TO standoffuser
USING (created_by = current_user);

CREATE POLICY allow_delete_to_standoffeditor ON standoff.document FOR DELETE TO standoffeditor
USING (true);


COMMIT;
