-- Revert set_meta_on_insert

BEGIN;

DROP FUNCTION standoff.set_meta_on_insert();

COMMIT;
