-- Verify text_document

BEGIN;

SELECT text FROM arb.text_document WHERE FALSE;

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'arb.text_document'::regclass
       AND tgname = 'insert_text_document';

SELECT has_table_privilege('arbuser', 'arb.text_document', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('arbeditor', 'arb.text_document', 'SELECT, INSERT, UPDATE, DELETE');

ROLLBACK;
