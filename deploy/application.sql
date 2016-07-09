-- Deploy application
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE arb.application (
       id varchar not null,
       description text,
       PRIMARY KEY (id));

GRANT SELECT ON TABLE arb.application TO arbuser, arbeditor, arbadmin;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE arb.application TO arbadmin;

COMMIT;
