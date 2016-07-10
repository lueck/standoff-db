-- Revert set_meta_on_update

BEGIN;

DROP FUNCTION standoff.set_meta_on_update();

COMMIT;
