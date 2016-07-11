-- Deploy ontology_resource
-- requires: ontology
-- requires: resource_type_application
-- requires: arbschema
-- requires: arbroles
-- requires: set_meta_on_update
-- requires: set_meta_on_insert
-- requires: adjust_privilege

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.ontology_resource (
	id serial not null,
	local_name varchar not null,
	ontology integer not null references standoff.ontology,
	definition xml,
	resource_type varchar references standoff.resource_type_application,
	created_at timestamp not null DEFAULT current_timestamp,
	created_by varchar not null,
	updated_at timestamp,
	updated_by varchar,
	gid varchar null,
	privilege integer not null DEFAULT 492,
	PRIMARY KEY (id),
	UNIQUE (ontology, local_name));


GRANT SELECT ON TABLE standoff.ontology_resource TO standoffuser;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE standoff.ontology_resource
      TO standoffeditor, standoffadmin;


GRANT USAGE ON SEQUENCE standoff.ontology_resource_id_seq
      TO standoffeditor, standoffadmin;


CREATE TRIGGER set_meta_on_insert BEFORE INSERT ON standoff.ontology_resource
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

CREATE TRIGGER set_meta_on_update BEFORE UPDATE ON standoff.ontology_resource
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_update();


CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON standoff.ontology_resource
    FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(492);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON standoff.ontology_resource
    FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(492);

COMMIT;
