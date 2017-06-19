-- Verify markup

BEGIN;

SELECT (document_id, text_range, source_range,
       markup_range_id, markup_id,
       created_at, created_by, updated_at, updated_by)
       FROM standoff.markup_range
       WHERE TRUE;

SELECT has_table_privilege('standoffuser', 'standoff.markup_range', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffeditor', 'standoff.markup_range', 'SELECT, INSERT, UPDATE, DELETE');
SELECT has_table_privilege('standoffadmin', 'standoff.markup_range', 'SELECT, INSERT, UPDATE, DELETE');

-- functions are stored on pg_proc system table.
SELECT 'standoff.get_markup_document'::regproc;
SELECT 'standoff.get_markup_created_by'::regproc;
SELECT 'standoff.get_markup_gid'::regproc;
SELECT 'standoff.get_markup_privilege'::regproc;


ROLLBACK;
