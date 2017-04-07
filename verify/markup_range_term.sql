-- Verify markup_range_term

BEGIN;

SELECT (local_name) FROM standoff.markup_range_term WHERE TRUE;

SELECT has_table_privilege('public', 'standoff.markup_range_term', 'SELECT');


ROLLBACK;
