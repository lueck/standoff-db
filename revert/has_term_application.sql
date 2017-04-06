-- Revert has_term_application

BEGIN;

REVOKE ALL PRIVILEGES ON FUNCTION standoff.has_term_application(int, varchar)
FROM standoffuser, standoffeditor, standoffadmin;

DROP FUNCTION standoff.has_term_application(int, varchar);

COMMIT;
