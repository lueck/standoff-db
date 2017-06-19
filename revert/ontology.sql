-- Revert ontology

BEGIN;

DROP TRIGGER set_meta_on_insert ON standoff.ontology;
DROP TRIGGER set_meta_on_update ON standoff.ontology;

DROP TRIGGER adjust_privilege_on_insert ON standoff.ontology;
DROP TRIGGER adjust_privilege_on_update ON standoff.ontology;

REVOKE ALL PRIVILEGES ON TABLE standoff.ontology
       FROM standoffuser, standoffeditor, standoffadmin;

REVOKE ALL PRIVILEGES ON SEQUENCE standoff.ontology_ontology_id_seq
       FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.ontology;

COMMIT;
