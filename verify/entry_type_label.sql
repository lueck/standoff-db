-- Verify entry_type_label

BEGIN;

SELECT (entry_type, language, label, description)
FROM standoff.entry_type_label WHERE FALSE;

ROLLBACK;
