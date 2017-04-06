-- Deploy has_term_application
-- requires: term
-- requires: application
-- requires: arbschema

BEGIN;

-- Returns true if the term given as first parameter has the
-- application given as second parameter.
CREATE OR REPLACE FUNCTION standoff.has_term_application (termId int, app varchar)
RETURNS boolean AS $$
	SELECT (SELECT application FROM standoff.term t WHERE t.id = termId) = app AS result;
$$ LANGUAGE SQL;

GRANT EXECUTE ON FUNCTION standoff.has_term_application (termId int, app varchar)
TO standoffuser, standoffeditor, standoffadmin;

COMMIT;
