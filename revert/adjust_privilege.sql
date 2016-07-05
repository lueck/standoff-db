-- Revert adjust_privilege

BEGIN;

DROP FUNCTION arb.adjust_privilege();

COMMIT;
