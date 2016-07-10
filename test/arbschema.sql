-- Plan the test.
BEGIN;
SELECT plan(1);

SELECT has_schema('standoff');

-- Clean up.
SELECT finish();
ROLLBACK;
