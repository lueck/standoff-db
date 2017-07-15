-- Verify sentence

BEGIN;

SELECT (document_id, text_range, source_range,
        sentence_number)
	FROM standoff.sentence WHERE TRUE;

SELECT 1/has_table_privilege('standoffuser', 'standoff.sentence', 'SELECT')::integer;
SELECT 1/has_table_privilege('standoffeditor', 'standoff.sentence', 'SELECT, INSERT, UPDATE, DELETE')::integer;
SELECT 1/has_table_privilege('standoffadmin', 'standoff.sentence', 'SELECT, INSERT, UPDATE, DELETE')::integer;

SELECT 1/(has_table_privilege('standoffuser', 'standoff.sentence', 'INSERT, UPDATE, DELETE')::integer - 1);


ROLLBACK;
