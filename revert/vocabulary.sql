-- Revert arb-db:vocabulary from pg

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.vocabulary
FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE IF EXISTS standoff.vocabulary;

COMMIT;
