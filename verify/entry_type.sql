-- Verify entry_type

BEGIN;

SELECT (entry_type) FROM standoff.entry_type WHERE FALSE;

ROLLBACK;
