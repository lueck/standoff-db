-- Verify corpus_document

BEGIN;

SELECT (corpus,
       document,
       created_at,
       created_by)
       FROM standoff.corpus_document WHERE FALSE;

SELECT has_table_privilege('standoffuser', 'standoff.corpus_document', 'SELECT, INSERT, DELETE');
SELECT has_table_privilege('standoffeditor', 'standoff.corpus_document', 'SELECT, INSERT, DELETE');
SELECT has_table_privilege('standoffadmin', 'standoff.corpus_document', 'SELECT, INSERT, DELETE');


SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.corpus_document'::regclass
       AND tgname = 'set_meta_on_insert';


SELECT 'standoff.create_document_corpus'::regproc;

SELECT pg_catalog.has_function_privilege('standoffuser', 'standoff.create_document_corpus()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffeditor', 'standoff.create_document_corpus()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffadmin', 'standoff.create_document_corpus()', 'EXECUTE');

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.document'::regclass
       AND tgname = 'create_document_corpus';


SELECT 'standoff.add_document_to_global_corpus'::regproc;

SELECT pg_catalog.has_function_privilege('standoffuser', 'standoff.add_document_to_global_corpus()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffeditor', 'standoff.add_document_to_global_corpus()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffadmin', 'standoff.add_document_to_global_corpus()', 'EXECUTE');


SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.document'::regclass
       AND tgname = 'add_document_to_global_corpus';


SELECT 'standoff.delete_document_from_corpus'::regproc;

SELECT pg_catalog.has_function_privilege('standoffuser', 'standoff.delete_document_from_corpus()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffeditor', 'standoff.delete_document_from_corpus()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffadmin', 'standoff.delete_document_from_corpus()', 'EXECUTE');

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.document'::regclass
       AND tgname = 's_delete_document_from_corpus';

ROLLBACK;
