-- Deploy sentence
-- requires: document
-- requires: arbschema
-- requires: arbroles
-- requires: document_range

BEGIN;

-- The text of a sentence is not stored in this table. But there are
-- ranges, from which the text can be restored from the document.

CREATE TABLE IF NOT EXISTS standoff.sentence (
       sentence_number serial not null,
       PRIMARY KEY (document_id, sentence_number))
       INHERITS (standoff.document_range);


GRANT SELECT ON TABLE standoff.sentence TO standoffuser;

GRANT SELECT, INSERT, DELETE ON TABLE standoff.sentence TO standoffeditor, standoffadmin;


CREATE INDEX IF NOT EXISTS sentence_text_range_idx
ON standoff.sentence
USING GIST (text_range);

CREATE INDEX IF NOT EXISTS sentence_source_range_idx
ON standoff.sentence
USING GIST (source_range);

COMMIT;
