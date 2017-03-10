-- Deploy token
-- requires: document
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.token (
       document integer not null references standoff.document ON DELETE CASCADE,
       number integer not null,
       token text not null,
       source_start integer,
       source_end integer,
       text_start integer,
       text_end integer,
       PRIMARY KEY (document, number));

GRANT SELECT, INSERT ON TABLE standoff.token TO standoffuser, standoffeditor, standoffadmin;
GRANT DELETE, UPDATE ON TABLE standoff.token TO standoffeditor, standoffadmin;

COMMIT;
