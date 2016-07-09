-- Verify document

BEGIN;

SELECT (id,
       reference,
       doc_encoded,
       md5,
       mimetype,
       source_uri,
       description,
       created_at,
       created_by,
       updated_at,
       updated_by,
       gid,
       privilege)
       FROM arb.document WHERE FALSE;

SELECT has_table_privilege('arbuser', 'arb.document', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('arbeditor', 'arb.document', 'SELECT, INSERT, UPDATE, DELETE');

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'arb.document'::regclass
       AND tgname = 'document_set_meta_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'arb.document'::regclass
       AND tgname = 'document_set_meta_on_update';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'arb.document'::regclass
       AND tgname = 'adjust_privilege_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'arb.document'::regclass
       AND tgname = 'adjust_privilege_on_update';

-- For verification of security policies, see unittests in ../test/document.sql

ROLLBACK;
