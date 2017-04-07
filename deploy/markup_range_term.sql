-- Deploy markup_range_term
-- requires: ontology
-- requires: term
-- requires: markup
-- requires: markup_range
-- requires: document

BEGIN;

CREATE OR REPLACE VIEW standoff.markup_range_term WITH (security_barrier) AS
       SELECT
       r.id,
       r.markup,
       r.document,
       m.term,
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
       LEFT JOIN standoff.markup m ON m.id = r.markup
       LEFT JOIN standoff.term t ON t.id = m.term
       LEFT JOIN standoff.ontology o ON o.id = t.ontology
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
