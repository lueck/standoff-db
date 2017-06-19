-- Verify document_range

BEGIN;

SELECT (document_id,
       text_range,
       source_range)
       FROM standoff.document_range WHERE FALSE;

SELECT has_table_privilege('standoffuser', 'standoff.document_range', 'SELECT');
SELECT has_table_privilege('standoffeditor', 'standoff.document_range', 'SELECT');
SELECT has_table_privilege('standoffadmin', 'standoff.document_range', 'SELECT');

ROLLBACK;
