-- Deploy term
-- requires: ontology
-- requires: application
-- requires: arbschema
-- requires: arbroles
-- requires: set_meta_on_update
-- requires: set_meta_on_insert
-- requires: adjust_privilege

BEGIN;

-- A term is a class, property etc. defined in an ontology.
CREATE TABLE IF NOT EXISTS standoff.term (
	id serial not null,           -- integer ID
	local_name varchar not null,  -- local part of the qualified name of the term
	ontology integer not null references standoff.ontology, -- relation to ontology
	application varchar references standoff.application,  -- whether it's markup, relation, attribute etc.
	created_at timestamp not null DEFAULT current_timestamp,
	created_by varchar not null,
	updated_at timestamp,
	updated_by varchar,
	-- FIXME: better use gid and privilege from ontology
	gid varchar null,
	privilege integer not null DEFAULT 292, -- #o444
	PRIMARY KEY (id),
	UNIQUE (ontology, local_name));


GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE standoff.term
      TO standoffuser, standoffeditor, standoffadmin;


GRANT SELECT, USAGE ON SEQUENCE standoff.term_id_seq
      TO standoffuser, standoffeditor, standoffadmin;


CREATE TRIGGER set_meta_on_insert BEFORE INSERT ON standoff.term
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

CREATE TRIGGER set_meta_on_update BEFORE UPDATE ON standoff.term
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_update();


CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON standoff.term
    FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(292);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON standoff.term
    FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(292);

COMMIT;
