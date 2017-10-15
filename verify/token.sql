-- Verify token

BEGIN;

SELECT (document_id,
       source_range,
       text_range,
       token_number,
       token,
       sentence_number,
       lemma,
       postag,
       tagset)
       FROM standoff.token WHERE FALSE;

SELECT 1/has_table_privilege('standoffuser', 'standoff.token', 'SELECT')::integer;
SELECT 1/has_table_privilege('standoffeditor', 'standoff.token', 'SELECT, INSERT, UPDATE, DELETE')::integer;
SELECT 1/has_table_privilege('standoffadmin', 'standoff.token', 'SELECT, INSERT, UPDATE, DELETE')::integer;

SELECT 1/(has_table_privilege('standoffuser', 'standoff.token', 'INSERT, UPDATE, DELETE')::integer - 1);

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.document'::regclass
       AND tgname = 'delete_on_document_delete';


SELECT 'standoff.delete_token'::regproc;


ROLLBACK;
