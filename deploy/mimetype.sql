-- Deploy mimetype
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE arb.mimetype (
       id varchar,
       application varchar references arb.application ON DELETE SET NULL,
       PRIMARY KEY (id));

GRANT SELECT ON TABLE arb.mimetype TO arbuser, arbeditor, arbadmin;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE arb.mimetype TO arbadmin;

COMMIT;
