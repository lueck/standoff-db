-- Revert token_frequency

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.token_frequency
       FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.token_frequency;

COMMIT;
