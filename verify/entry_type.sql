-- Verify entry_type

BEGIN;

SELECT (id) FROM arb.entry_type WHERE FALSE;

ROLLBACK;
