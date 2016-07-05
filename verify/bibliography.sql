-- Verify bibliography

BEGIN;

SELECT (id,
       entry_key,
       entry_type,
       created_at,
       created_by,
       updated_at,
       updated_by,
       gid,
       privilege)
       FROM arb.bibliography WHERE FALSE;

SELECT has_table_privilege('arbuser', 'arb.bibliography', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('arbeditor', 'arb.bibliography', 'SELECT, INSERT, UPDATE, DELETE');

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'arb.bibliography'::regclass
       AND tgname = 'bibliography_set_meta_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'arb.bibliography'::regclass
       AND tgname = 'bibliography_set_meta_on_update';

-- For verification of security policies, see unittests in ../test/bibliography.sql

ROLLBACK;
