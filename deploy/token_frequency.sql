-- Deploy token_frequency
-- requires: token
-- requires: corpus
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.token_frequency (
       token_frequency_id serial not null primary key,
       corpus_id integer not null references standoff.corpus ON DELETE CASCADE,
       token text not null,
       frequency integer not null default 0,
       UNIQUE (corpus_id, token));

-- Only select is allowed. Insertion and deletion is completely done
-- via triggers.
GRANT SELECT ON TABLE standoff.token_frequency
TO standoffuser, standoffeditor, standoffadmin;

COMMIT;
