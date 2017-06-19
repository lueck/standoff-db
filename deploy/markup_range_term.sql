-- Deploy markup_range_term
-- requires: ontology
-- requires: term
-- requires: markup
-- requires: markup_range
-- requires: document

BEGIN;

CREATE OR REPLACE VIEW standoff.markup_range_term WITH (security_barrier) AS
       SELECT
       r.markup_range_id,
       r.markup_id,
       r.document_id,
       m.term_id,
       t.local_name,
       o.iri||o.namespace_delimiter||t.local_name AS qualified_name,
       o.prefix,
       o.prefix||':'||t.local_name AS prefixed_name,
       r.text_range,
       r.source_range,
       r.created_by,
       r.created_at,
       r.updated_by,
       r.updated_at
       FROM standoff.markup_range r
       LEFT JOIN standoff.markup m USING (markup_id) -- ON m.markup_id = r.markup_id
       LEFT JOIN standoff.term t USING (term_id) -- ON t.term_id = m.term_id
       LEFT JOIN standoff.ontology o USING (ontology_id) -- ON o.ontology_id = t.ontology_id
       -- Views are accessed with the permission of the its
       -- creator. So RLS is bypassed and we have to mimic it.
       WHERE m.created_by = current_user    -- allow owner of markup
       	     OR r.created_by = current_user -- allow owner of range
	     OR ((m.privilege & 32) = 32    -- test privs for group member
             	 AND pg_has_role(m.gid, 'MEMBER'))
	     OR (m.privilege & 4) = 4       -- test privs for others
	     OR pg_has_role('standoffeditor', 'MEMBER'); -- allow editor

GRANT SELECT ON standoff.markup_range_term TO standoffuser, standoffeditor;

COMMIT;
