-- Deploy frequency_update_method
-- requires: arbschema
-- requires: arbroles

BEGIN;

-- Configure the update method for token frequencies. Returns 'none'
-- by default. To use the triggers defined in upd_freg_by_docfreq.sql
-- replace this method with one that returns 'token_frequency'.
CREATE OR REPLACE FUNCTION standoff.frequency_update_method()
       RETURNS varchar(50)
       AS 'SELECT ''none''::varchar(50);'
       LANGUAGE SQL
       IMMUTABLE;

GRANT EXECUTE ON FUNCTION standoff.frequency_update_method()
TO PUBLIC;

COMMIT;
