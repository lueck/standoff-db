-- Revert ontology_term

BEGIN;

REVOKE ALL PRIVILEGES ON TABLE standoff.ontology_term
       FROM standoffuser, standoffeditor, standoffadmin;

DROP VIEW standoff.ontology_term;

COMMIT;
