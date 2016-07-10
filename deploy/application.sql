-- Deploy application
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE standoff.application (
       id varchar not null,
       description text,
       PRIMARY KEY (id));

GRANT SELECT ON TABLE standoff.application TO standoffuser, standoffeditor, standoffadmin;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE standoff.application TO standoffadmin;

COMMIT;
