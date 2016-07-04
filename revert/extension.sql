-- Revert extension

BEGIN;

-- We do *not* drop this extension, which may be used by others
-- projects.

-- DROP EXTENSION IF EXISTS ""uuid-ossp";

COMMIT;
