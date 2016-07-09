-- Deploy document
-- requires: bibliography
-- requires: arbschema
-- requires: arbroles
-- requires: adjust_privilege
-- requires: set_meta_on_insert
-- requires: set_meta_on_update
-- requires: extension

BEGIN;

CREATE TABLE IF NOT EXISTS arb.document (
	id uuid not null,
	reference uuid not null references arb.bibliography,
	-- for all types of documents
	doc_encoded Base64 not null,
	md5 uuid not null, -- md5 hash of unencoded document/file
	mimetype varchar not null references arb.mimetype,
	source_uri varchar,
	description text,
	-- for text types
	text_encoding varchar,
	text_offset integer,
	xml_offset_xpointer varchar,
	-- meta data for all types of documents
        created_at timestamp not null,
        created_by varchar not null,
        updated_at timestamp,
        updated_by varchar,
        gid varchar,
        privilege integer not null DEFAULT 509,
	PRIMARY KEY (id),
	UNIQUE (md5));

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE arb.document TO arbuser, arbeditor;

CREATE TRIGGER document_set_meta_on_insert BEFORE INSERT ON arb.document
    FOR EACH ROW EXECUTE PROCEDURE arb.set_meta_on_insert();

CREATE TRIGGER document_set_meta_on_update BEFORE UPDATE ON arb.document
    FOR EACH ROW EXECUTE PROCEDURE arb.set_meta_on_update();

CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON arb.document
       FOR EACH ROW EXECUTE PROCEDURE arb.adjust_privilege(484);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON arb.document
       FOR EACH ROW EXECUTE PROCEDURE arb.adjust_privilege(484);

-- Note: For setting a DEFAULT value for document.gid alter this
-- trigger and pass the gid as an argument to the trigger, like
-- arb.set_gid('biblio').

-- FIXME:
--CREATE TRIGGER document_set_gid_on_insert BEFORE INSERT ON arb.document
--       FOR EACH ROW EXECUTE PROCEDURE arb.set_gid();

-- FIXME:
--CREATE TRIGGER document_adjust_privilege BEFORE INSERT ON arb.document
--       FOR EACH ROW EXECUTE PROCEDURE arb.adjust_privilege();


ALTER TABLE arb.document ENABLE ROW LEVEL SECURITY;

-- Note: We do bitwise AND on the integer value of privilege and then
-- test if it equals the bitmask. privilege & 16 = 16 is the same as
-- privilege & (1<<4) = (1<<4), which may be more readable. For
-- performance reasons we replace (1<<4) with the count itself.

CREATE POLICY allow_select ON arb.document FOR SELECT
USING (true);

CREATE POLICY assert_well_formed ON arb.document FOR INSERT TO arbuser
WITH CHECK (created_by = current_user);

CREATE POLICY assert_well_formed_null ON arb.document FOR INSERT TO arbuser
WITH CHECK (created_by is null); -- if null, then is set to
				 -- current_user by trigger.

CREATE POLICY allow_insert_to_arbeditor ON arb.document FOR INSERT TO arbeditor
WITH CHECK (true);

CREATE POLICY allow_update_to_creator ON arb.document FOR UPDATE TO arbuser
USING (created_by = current_user);

CREATE POLICY allow_update_to_group_member ON arb.document FOR UPDATE TO arbuser
USING ((privilege & 16) = 16
        AND pg_has_role(gid, 'MEMBER'));

CREATE POLICY allow_update_to_others ON arb.document FOR UPDATE TO arbuser
USING (privilege & 2 = 2);

CREATE POLICY allow_update_to_arbeditor ON arb.document FOR UPDATE TO arbeditor
USING (true);

CREATE POLICY allow_delete_to_creator ON arb.document FOR DELETE TO arbuser
USING (created_by = current_user);

CREATE POLICY allow_delete_to_arbeditor ON arb.document FOR DELETE TO arbeditor
USING (true);

COMMIT;
