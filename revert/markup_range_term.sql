-- Revert markup_range_term

BEGIN;

REVOKE ALL PRIVILEGES ON standoff.markup_range_term
FROM public, standoffeditor, standoffuser, standoffadmin;

DROP VIEW IF EXISTS standoff.markup_range_term;

COMMIT;
