-- Verify language

BEGIN;

SELECT (language) FROM standoff.language WHERE FALSE;

ROLLBACK;
