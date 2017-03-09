-- Revert corpus_document

BEGIN;

DROP POLICY IF EXISTS rowcreator_select ON standoff.corpus_document;
DROP POLICY IF EXISTS creator_select ON standoff.corpus_document;
DROP POLICY IF EXISTS creator_insert ON standoff.corpus_document;
DROP POLICY IF EXISTS creator_delete ON standoff.corpus_document;
DROP POLICY IF EXISTS group_select ON standoff.corpus_document;
DROP POLICY IF EXISTS group_insert ON standoff.corpus_document;
DROP POLICY IF EXISTS group_delete ON standoff.corpus_document;
DROP POLICY IF EXISTS others_select ON standoff.corpus_document;
DROP POLICY IF EXISTS others_insert ON standoff.corpus_document;
DROP POLICY IF EXISTS others_delete ON standoff.corpus_document;
DROP POLICY IF EXISTS standoffeditor_all ON standoff.corpus_document;

DROP POLICY IF EXISTS debug ON standoff.corpus_document;

DROP TRIGGER create_document_corpus ON standoff.document;

DROP FUNCTION standoff.create_document_corpus();

DROP TRIGGER add_document_to_global_corpus ON standoff.document;

DROP FUNCTION standoff.add_document_to_global_corpus();

DROP TRIGGER set_meta_on_insert ON standoff.corpus_document;

DROP TRIGGER document_corpus_size1 ON standoff.corpus_document;

DROP TRIGGER s_delete_document_from_corpus ON standoff.document;

DROP FUNCTION standoff.delete_document_from_corpus();

DROP FUNCTION standoff.document_corpus_size1();

REVOKE ALL PRIVILEGES ON TABLE standoff.corpus_document
       FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.corpus_document;

COMMIT;
