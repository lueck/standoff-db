-- Deploy text_document
-- requires: document
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE VIEW arb.text_document AS
       SELECT
	d.id,
	d.reference,
	d.source_md5,
	d.source_base64,
	d.source_uri,
	d.source_charset,
	d.mimetype,
	d.description,
	decode(d.source_base64, 'base64') AS text,
	d.created_at,
	d.created_by,
	d.updated_at,
	d.updated_by,
	d.gid,
	d.privilege
	FROM arb.document d
	WHERE d.mimetype LIKE 'text/%';

GRANT INSERT, SELECT, UPDATE, DELETE ON arb.text_document TO arbuser, arbeditor;

CREATE FUNCTION arb.insert_text_document() RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO arb.document
	       (id, reference, source_md5, source_base64, source_uri, source_charset,
	       	mimetype, description, created_at, created_by, updated_at, updated_by,
		gid, privilege)
		VALUES 
	       (coalesce(NEW.id, uuid_generate_v1()),
	       	NEW.reference,
		md5(NEW.text)::uuid,
		encode(NEW.text, 'base64'),
		NEW.source_uri,
		NEW.source_charset,
		NEW.mimetype,
		NEW.description,
		NEW.created_at,
		NEW.created_by,
		NEW.updated_at,
		NEW.updated_by,
		NEW.gid,
		coalesce(NEW.privilege, 509));
	RETURN NEW;
END; $$ LANGUAGE 'plpgsql';


CREATE TRIGGER insert_text_document INSTEAD OF INSERT ON arb.text_document
       FOR EACH ROW EXECUTE PROCEDURE arb.insert_text_document();
		
	       

COMMIT;
