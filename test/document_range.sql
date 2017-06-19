-- Start transaction and plan the tests
BEGIN;
SELECT plan(1);

-- Run the tests.
SELECT indexes_are('standoff', 'document_range',
       ARRAY['document_range_text_range_idx',
             'document_range_source_range_idx',
	     'document_range_document_id_idx']);

-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
