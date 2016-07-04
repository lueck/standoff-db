-- Deploy extension
-- requires: arbroles

BEGIN;

SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
RESET client_min_messages;

COMMIT;
