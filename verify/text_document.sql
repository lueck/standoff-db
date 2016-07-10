-- Verify text_document

BEGIN;

SELECT text FROM standoff.text_document WHERE FALSE;

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.text_document'::regclass
       AND tgname = 'insert_text_document';

SELECT has_table_privilege('standoffuser', 'standoff.text_document', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffeditor', 'standoff.text_document', 'SELECT, INSERT, UPDATE, DELETE');

ROLLBACK;
