-- Deploy ontology
-- requires: arbschema
-- requires: arbroles
-- requires: set_meta_on_insert
-- requires: adjust_privilege
-- requires: extension

-- Note: 493 is #o755

BEGIN;

-- The namespace_delimiter will usually be either a hash or a slash,
-- depending of the ontology is using a hash namespace or a slash
-- namespace. See
-- https://www.w3.org/2001/sw/BestPractices/VM/http-examples/2006-01-18/#naming
-- for best practices.
CREATE TABLE IF NOT EXISTS standoff.ontology (
	ontology_id serial not null,      -- integer ID
	iri varchar not null,             -- the ontology's IRI
	version_iri varchar,              -- the IRI with a version number
	version_info varchar not null DEFAULT 'NO VERSION',  -- a version info
	namespace_delimiter varchar,      -- delimiter between namespace and local names
	prefix varchar,                   -- the xmlns prefix from the file
	definition text,                  -- file contents with the ontology's definition
	closed boolean DEFAULT false,     -- no operation on terms when true
	deprecated boolean DEFAULT false, -- terms cannot be applied any more when true
	created_at timestamp not null DEFAULT current_timestamp,
	created_by varchar not null,
	updated_at timestamp,
	updated_by varchar,
	gid varchar null,
	privilege integer not null DEFAULT 493,
	PRIMARY KEY (ontology_id),
	UNIQUE (iri, version_info),
	UNIQUE (version_iri));


GRANT SELECT, INSERT, UPDATE ON TABLE standoff.ontology TO standoffuser;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE standoff.ontology
      TO standoffeditor, standoffadmin;


GRANT SELECT, USAGE ON SEQUENCE standoff.ontology_ontology_id_seq TO standoffuser, standoffeditor, standoffadmin;


CREATE TRIGGER set_meta_on_insert BEFORE INSERT ON standoff.ontology
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

CREATE TRIGGER set_meta_on_update BEFORE UPDATE ON standoff.ontology
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_update();


CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON standoff.ontology
    FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(493);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON standoff.ontology
    FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(493);

COMMIT;
