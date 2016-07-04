-- Revert set_meta_on_update

BEGIN;

DROP FUNCTION arb.set_meta_on_update();

COMMIT;
