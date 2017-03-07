-- Verify corpus

BEGIN;

SELECT (id,
       corpus_type,
       title,
       description,
       created_at,
       created_by,
       updated_at,
       updated_by,
       gid,
       privilege)
       FROM standoff.corpus WHERE FALSE;

SELECT has_table_privilege('standoffuser', 'standoff.corpus', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffeditor', 'standoff.corpus', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffadmin', 'standoff.corpus', 'SELECT, INSERT, UPDATE, DELETE');

SELECT has_sequence_privilege('standoffuser', 'standoff.corpus_id_seq', 'SELECT, UPDATE');
SELECT has_sequence_privilege('standoffeditor', 'standoff.corpus_id_seq', 'SELECT, UPDATE');
SELECT has_sequence_privilege('standoffadmin', 'standoff.corpus_id_seq', 'SELECT, UPDATE');

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.corpus'::regclass
       AND tgname = 'corpus_set_meta_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.corpus'::regclass
       AND tgname = 'corpus_set_meta_on_update';


-- For verification of security policies, see unittests in ../test/corpus.sql

ROLLBACK;
