-- Verify language

BEGIN;

SELECT (id) FROM standoff.language WHERE FALSE;

ROLLBACK;
