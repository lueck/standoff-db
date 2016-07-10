-- Verify entry_type

BEGIN;

SELECT (id) FROM standoff.entry_type WHERE FALSE;

ROLLBACK;
