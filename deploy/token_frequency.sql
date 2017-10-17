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

GRANT SELECT, INSERT ON TABLE standoff.token_frequency
TO standoffeditor, standoffadmin;

GRANT USAGE ON SEQUENCE standoff.token_frequency_token_frequency_id_seq
TO standoffeditor, standoffadmin;


-- We use rls to keep things consistent: Only allow to insert to rows
-- belonging to a document corpus.
ALTER TABLE standoff.token_frequency ENABLE ROW LEVEL SECURITY;

CREATE POLICY assert_well_formed ON standoff.token_frequency FOR INSERT TO standoffeditor
WITH CHECK (standoff.corpus_get_corpus_type(corpus_id) = 'document');

CREATE POLICY allow_select ON standoff.token_frequency FOR SELECT TO PUBLIC
USING (true);


COMMIT;
