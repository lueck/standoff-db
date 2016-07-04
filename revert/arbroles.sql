-- Revert arbroles

BEGIN;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA arb FROM arbuser, arbeditor, arbadmin;
REVOKE USAGE ON SCHEMA arb FROM arbuser, arbeditor, arbadmin;

DROP ROLE IF EXISTS arbuser, arbeditor, arbadmin;

COMMIT;
