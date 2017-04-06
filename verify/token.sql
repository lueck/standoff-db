-- Verify token

BEGIN;

SELECT (document,
       number,
       token,
       lemma,
       source_start,
       source_end,
       text_start,
       text_end)
       FROM standoff.token WHERE FALSE;

SELECT has_table_privilege('standoffuser', 'standoff.token', 'SELECT, INSERT');
SELECT has_table_privilege('standoffeditor', 'standoff.token', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffadmin', 'standoff.token', 'SELECT, INSERT, UPDATE, DELETE');

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.document'::regclass
       AND tgname = 'delete_on_document_delete';


SELECT 'standoff.delete_token'::regproc;


ROLLBACK;
