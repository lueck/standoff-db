-- Verify arb-db:bibliography_field on pg

BEGIN;

SELECT (bibliography_id,
       field_type,
       val,
       created_at,
       created_by,
       updated_at,
       updated_by,
       gid,
       privilege
       ) FROM standoff.bibliography_field WHERE TRUE;

SELECT has_table_privilege('standoffuser', 'standoff.bibliography_field', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffeditor', 'standoff.bibliography_field', 'SELECT, INSERT, UPDATE, DELETE');

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.bibliography_field'::regclass
       AND tgname = 'bibliography_set_meta_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.bibliography_field'::regclass
       AND tgname = 'bibliography_set_meta_on_update';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.bibliography_field'::regclass
       AND tgname = 'adjust_privilege_on_insert';

SELECT 1/count(tgname) FROM pg_trigger t
       WHERE NOT tgisinternal
       AND tgrelid = 'standoff.bibliography_field'::regclass
       AND tgname = 'adjust_privilege_on_update';

-- For verification of security policies, see unittests in ../test/bibliography.sql


ROLLBACK;
