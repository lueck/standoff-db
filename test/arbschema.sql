-- Plan the test.
BEGIN;
SELECT plan(1);

SELECT has_schema('arb');

-- Clean up.
SELECT finish();
ROLLBACK;
