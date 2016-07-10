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

CREATE TABLE IF NOT EXISTS arb.document (
	id uuid not null,
	reference uuid not null references arb.bibliography,
	source_md5 uuid not null,
	source_base64 text not null,
	source_uri varchar,
	source_charset varchar,
	mimetype varchar not null references arb.mimetype,
	description text,
	-- for text types
	charset varchar,
	text_offset integer,
	xml_offset_xpointer varchar,
	-- meta data for all types of documents
        created_at timestamp not null,
        created_by varchar not null,
        updated_at timestamp,
        updated_by varchar,
        gid varchar,
        privilege integer not null DEFAULT 365,
	PRIMARY KEY (id),
	UNIQUE (source_md5));


GRANT SELECT, INSERT, DELETE ON TABLE arb.document TO arbuser, arbeditor, arbadmin;


-- UPDATE on source_base64 is not allowed to anybody, until there's a mechanism to
-- adjust the offset pointers of markup ranges.
GRANT UPDATE (reference, source_uri, source_charset, mimetype, description, updated_at, updated_by) ON TABLE arb.document TO arbeditor, arbadmin;


CREATE TRIGGER document_set_meta_on_insert BEFORE INSERT ON arb.document
    FOR EACH ROW EXECUTE PROCEDURE arb.set_meta_on_insert();

CREATE TRIGGER document_set_meta_on_update BEFORE UPDATE ON arb.document
    FOR EACH ROW EXECUTE PROCEDURE arb.set_meta_on_update();


CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON arb.document
       FOR EACH ROW EXECUTE PROCEDURE arb.adjust_privilege(365);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON arb.document
       FOR EACH ROW EXECUTE PROCEDURE arb.adjust_privilege(365);


-- Note: For setting a DEFAULT value for document.gid alter this
-- trigger and pass the gid as an argument to the trigger, like
-- arb.set_gid('biblio').

-- FIXME:
--CREATE TRIGGER document_set_gid_on_insert BEFORE INSERT ON arb.document
--       FOR EACH ROW EXECUTE PROCEDURE arb.set_gid();

-- FIXME:
--CREATE TRIGGER document_adjust_privilege BEFORE INSERT ON arb.document
--       FOR EACH ROW EXECUTE PROCEDURE arb.adjust_privilege();


CREATE FUNCTION arb.set_document_md5() RETURNS TRIGGER AS $$
       BEGIN
	NEW.source_md5 = coalesce(md5(decode(NEW.source_base64, 'base64'))::uuid, OLD.source_base64::uuid);
	RETURN NEW;
	END; $$ LANGUAGE 'plpgsql';

CREATE TRIGGER set_md5_on_insert BEFORE INSERT ON arb.document
       FOR EACH ROW EXECUTE PROCEDURE arb.set_document_md5();

CREATE TRIGGER set_md5_on_update BEFORE UPDATE ON arb.document
       FOR EACH ROW EXECUTE PROCEDURE arb.set_document_md5();



COMMIT;
