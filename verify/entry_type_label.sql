-- Verify entry_type_label

BEGIN;

SELECT (entry_type, language, label, description)
FROM arb.entry_type_label WHERE FALSE;

ROLLBACK;
