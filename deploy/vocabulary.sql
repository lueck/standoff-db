-- Deploy arb-db:vocabulary to pg
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.vocabulary (
       token_int SERIAL NOT NULL PRIMARY KEY, -- interger representation of the token
       token text NOT NULL,		      -- the token (or lemma or stemma)
       CONSTRAINT unique_token UNIQUE (token));


GRANT SELECT, INSERT ON TABLE standoff.vocabulary TO standoffuser;

GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE standoff.vocabulary
TO standoffeditor, standoffadmin;

COMMIT;
