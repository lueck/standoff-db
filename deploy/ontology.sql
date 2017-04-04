-- Deploy ontology
-- requires: arbschema
-- requires: arbroles
-- requires: set_meta_on_insert
-- requires: adjust_privilege
-- requires: extension

-- Note: 492 is #o754

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.ontology (
	id serial not null,
	namespace varchar not null,
	version varchar,
	definition text,
	created_at timestamp not null DEFAULT current_timestamp,
	created_by varchar not null,
	updated_at timestamp,
	updated_by varchar,
	gid varchar null,
	privilege integer not null DEFAULT 492,
	PRIMARY KEY (id),
	UNIQUE (namespace, version));


GRANT SELECT ON TABLE standoff.ontology TO standoffuser;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE standoff.ontology
      TO standoffeditor, standoffadmin;


GRANT USAGE ON SEQUENCE standoff.ontology_id_seq TO standoffeditor, standoffadmin;


CREATE TRIGGER set_meta_on_insert BEFORE INSERT ON standoff.ontology
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

CREATE TRIGGER set_meta_on_update BEFORE UPDATE ON standoff.ontology
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_update();


CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON standoff.ontology
    FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(492);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON standoff.ontology
    FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(492);

COMMIT;
