-- Revert sentence

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.sentence
FROM standoffuser, standoffeditor, standoffadmin;

DROP INDEX IF EXISTS standoff.sentence_text_range_idx;
DROP INDEX IF EXISTS standoff.sentence_source_range_idx;

DROP TABLE IF EXISTS standoff.sentence;

COMMIT;
