-- Revert adjust_privilege

BEGIN;

DROP FUNCTION standoff.adjust_privilege();

COMMIT;
