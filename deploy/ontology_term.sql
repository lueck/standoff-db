-- Deploy ontology_term
-- requires: ontology
-- requires: ontology_resource
-- requires: arbschema
-- requires: arbroles

BEGIN;

-- A view that shows terms together with their ontology.
CREATE VIEW standoff.ontology_term AS
       SELECT
	t.term_id,
	o.ontology_id,
       	o.iri,
	o.version_iri,
       	t.local_name,
	o.namespace_delimiter,
       	o.iri||o.namespace_delimiter||t.local_name AS qualified_name,
	o.prefix,
	o.prefix||':'||t.local_name AS prefixed_name,
       	t.application,
       	t.created_at,
       	t.created_by,
       	t.updated_at,
	t.updated_by,
	t.gid,
	t.privilege
       FROM standoff.term t
       LEFT JOIN standoff.ontology o USING (ontology_id);

GRANT SELECT ON TABLE standoff.ontology_term
      TO standoffuser, standoffeditor, standoffadmin;


COMMIT;
