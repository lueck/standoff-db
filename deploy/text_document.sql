-- Deploy text_document
-- requires: document
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE VIEW standoff.text_document AS
       SELECT
	d.document_id,
	d.bibliography_id,
	d.source_md5,
	d.source_base64,
	d.source_uri,
	d.source_charset,
	d.mimetype,
	d.description,
	d.plaintext,
	convert_from(decode(d.source_base64, 'base64'), 'utf-8') AS text,
	d.created_at,
	d.created_by,
	d.updated_at,
	d.updated_by,
	d.gid,
	d.privilege
	FROM standoff.document d
	WHERE d.mimetype LIKE 'text/%';

GRANT INSERT, SELECT, UPDATE, DELETE ON standoff.text_document TO standoffuser, standoffeditor;

CREATE FUNCTION standoff.insert_text_document() RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO standoff.document
	       (bibliography_id, source_md5, source_base64, source_uri, source_charset,
	       	mimetype, description, plaintext,
		created_at, created_by, updated_at, updated_by,
		gid, privilege)
		VALUES 
	       (NEW.bibliography_id,
		md5(NEW.text)::uuid,
		encode(NEW.text::bytea, 'base64'),
		NEW.source_uri,
		NEW.source_charset,
		NEW.mimetype,
		NEW.description,
		NEW.plaintext,
		NEW.created_at,
		NEW.created_by,
		NEW.updated_at,
		NEW.updated_by,
		NEW.gid,
		coalesce(NEW.privilege, 509));
	RETURN NEW;
END; $$ LANGUAGE 'plpgsql';


CREATE TRIGGER insert_text_document INSTEAD OF INSERT ON standoff.text_document
       FOR EACH ROW EXECUTE PROCEDURE standoff.insert_text_document();
		
	       

COMMIT;
