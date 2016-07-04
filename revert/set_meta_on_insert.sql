-- Revert set_meta_on_insert

BEGIN;

DROP FUNCTION arb.set_meta_on_insert();

COMMIT;
