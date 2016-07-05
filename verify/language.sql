-- Verify language

BEGIN;

SELECT (id) FROM arb.language WHERE FALSE;

ROLLBACK;
