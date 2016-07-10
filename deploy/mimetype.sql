-- Deploy mimetype
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE standoff.mimetype (
       id varchar,
       application varchar references standoff.application ON DELETE SET NULL,
       PRIMARY KEY (id));

GRANT SELECT ON TABLE standoff.mimetype TO standoffuser, standoffeditor, standoffadmin;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE standoff.mimetype TO standoffadmin;

COMMIT;
