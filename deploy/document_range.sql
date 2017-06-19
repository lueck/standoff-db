-- Deploy document_range
-- requires: arbschema
-- requires: document

BEGIN;


-- A basic relation for portions of a document. You may inherit from
-- it, so all portions of whatever type are in one common relation and
-- we can easily query for overlapping, containment etc.
CREATE TABLE IF NOT EXISTS standoff.document_range (
       document_id int not null references standoff.document,
       text_range int4range,     -- text range given by start and end
				 -- character offset in relation to
				 -- text layer.
       source_range int4range);  -- text range given by start and end
				 -- character offset in relation to
				 -- source file.

CREATE INDEX IF NOT EXISTS document_range_text_range_idx
ON standoff.document_range
USING GIST (text_range);

CREATE INDEX IF NOT EXISTS document_range_source_range_idx
ON standoff.document_range
USING GIST (source_range);

CREATE INDEX IF NOT EXISTS document_range_document_id_idx
ON standoff.document_range (document_id);

GRANT SELECT ON TABLE standoff.document_range
TO standoffuser, standoffeditor, standoffadmin;

COMMIT;
