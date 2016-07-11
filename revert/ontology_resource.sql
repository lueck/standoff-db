-- Revert ontology_resource

BEGIN;

DROP TRIGGER set_meta_on_insert ON standoff.ontology_resource;
DROP TRIGGER set_meta_on_update ON standoff.ontology_resource;

DROP TRIGGER adjust_privilege_on_insert ON standoff.ontology_resource;
DROP TRIGGER adjust_privilege_on_update ON standoff.ontology_resource;

REVOKE ALL PRIVILEGES ON TABLE standoff.ontology_resource
       FROM standoffuser, standoffeditor, standoffadmin;

REVOKE ALL PRIVILEGES ON SEQUENCE standoff.ontology_resource_id_seq
       FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.ontology_resource;


COMMIT;
