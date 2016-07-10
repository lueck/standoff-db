-- Verify document

BEGIN;

SELECT (id,
       reference,
       source_base64,
       source_md5,
       source_uri,
       source_charset,
       mimetype,
       description,
       created_at,
       created_by,
       updated_at,
       updated_by,
       gid,
       privilege)
       FROM standoff.document WHERE FALSE;

SELECT has_table_privilege('standoffuser', 'standoff.document', 'SELECT, INSERT, DELETE');
SELECT has_table_privilege('standoffuser', 'standoff.document', 'UPDATE');
SELECT has_table_privilege('standoffeditor', 'standoff.document', 'SELECT, INSERT, DELETE');

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.document'::regclass
       AND tgname = 'document_set_meta_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.document'::regclass
       AND tgname = 'document_set_meta_on_update';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.document'::regclass
       AND tgname = 'adjust_privilege_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.document'::regclass
       AND tgname = 'adjust_privilege_on_update';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.document'::regclass
       AND tgname = 'set_md5_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.document'::regclass
       AND tgname = 'set_md5_on_update';

-- functions are stored on pg_proc system table.
SELECT 'standoff.set_document_md5'::regproc;

SELECT pg_catalog.has_function_privilege('standoffuser', 'standoff.set_document_md5()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffeditor', 'standoff.set_document_md5()', 'EXECUTE');
SELECT pg_catalog.has_function_privilege('standoffadmin', 'standoff.set_document_md5()', 'EXECUTE');

-- For verification of security policies, see unittests in ../test/document.sql

ROLLBACK;
