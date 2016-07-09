-- Revert mimetype

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE arb.mimetype FROM arbuser, arbeditor, arbadmin;

DROP TABLE arb.mimetype;

COMMIT;
