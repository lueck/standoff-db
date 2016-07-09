-- Revert application

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE arb.application FROM arbuser, arbeditor, arbadmin;

DROP TABLE arb.application;

COMMIT;
