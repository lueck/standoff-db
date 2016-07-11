-- Deploy markup_resource
-- requires: ontology
-- requires: ontology_resource
-- requires: system_prefix
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE VIEW standoff.markup_resource AS
       SELECT
	r.id,
       	o.namespace,
       	r.local_name,
       	o.namespace||r.local_name AS qualified_name,
	p.prefix,
	p.prefix||':'||r.local_name AS prefixed_name,
       	r.definition,
       	r.resource_type,
       	r.created_at,
       	r.created_by,
       	r.updated_at,
	r.updated_by,
	r.gid,
	r.privilege
       FROM standoff.ontology o, standoff.ontology_resource r, standoff.system_prefix p
       WHERE r.ontology = o.id AND p.namespace = o.namespace;


GRANT SELECT ON TABLE standoff.markup_resource
      TO standoffuser, standoffeditor, standoffadmin;


COMMIT;
