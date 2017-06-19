-- Deploy has_term_application
-- requires: term
-- requires: application
-- requires: arbschema

BEGIN;

-- Returns true if the term given as first parameter has the
-- application given as second parameter.
CREATE OR REPLACE FUNCTION standoff.has_term_application (term_id int, app varchar)
RETURNS boolean AS $$
	SELECT (SELECT application FROM standoff.term t
	        WHERE t.term_id = has_term_application.term_id)
		= app AS result;
$$ LANGUAGE SQL;

GRANT EXECUTE ON FUNCTION standoff.has_term_application (int, varchar)
TO standoffuser, standoffeditor, standoffadmin;

COMMIT;
