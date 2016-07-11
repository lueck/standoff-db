-- Deploy resource_type_application
-- requires: application
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.resource_type_application (
	qualified_name varchar not null,
	application varchar not null references standoff.application,
	PRIMARY KEY (qualified_name));

GRANT SELECT ON TABLE standoff.resource_type_application TO standoffuser;

GRANT INSERT, UPDATE, SELECT, DELETE ON TABLE standoff.resource_type_application
      TO standoffeditor, standoffadmin;

COMMIT;
