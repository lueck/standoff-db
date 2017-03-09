-- Deploy corpus_document
-- requires: document
-- requires: corpus

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.corpus_document (
       corpus integer not null references standoff.corpus,
       document integer not null references standoff.document,
       created_at timestamp not null,
       created_by varchar not null,
       -- A unique index on (corpus, document) asserts that documents
       -- are not in a corpus multiple times. It also prevents adding
       -- to the global corpus manually, provided that triggers add it
       -- there on the creation of the document.
       UNIQUE (corpus, document));

-- We never update rows in this crossing table.
GRANT INSERT, SELECT, DELETE ON TABLE standoff.corpus_document
      TO standoffuser, standoffeditor, standoffadmin;

CREATE TRIGGER set_meta_on_insert BEFORE INSERT ON standoff.corpus_document
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

-- Trigger for adding new document to global corpus.

CREATE OR REPLACE FUNCTION standoff.add_document_to_global_corpus()
       RETURNS TRIGGER AS $$
       BEGIN
       INSERT INTO standoff.corpus_document (document, corpus, created_at, created_by)
       VALUES (NEW.id,
       	       (SELECT id from standoff.corpus WHERE corpus_type = 'global'),
	       current_timestamp,
	       current_user);
       RETURN NEW;
       END;
       $$ LANGUAGE plpgsql
       -- Execute this function with the privileges of it's definer in
       -- order to bypass RLS which enforces that corpus_type is
       -- 'collection'.
       SECURITY DEFINER;

CREATE TRIGGER add_document_to_global_corpus AFTER INSERT ON standoff.document
       FOR EACH ROW EXECUTE PROCEDURE standoff.add_document_to_global_corpus();

-- Trigger for creating a corpus with only the new document.

CREATE OR REPLACE FUNCTION standoff.create_document_corpus()
       RETURNS TRIGGER AS $$
       BEGIN
       INSERT INTO standoff.corpus
       	      (corpus_type, title, description, created_at, created_by, gid, privilege)
       	      VALUES ('document',
       	       	      'Document corpus ' || NEW.id :: text,
	       	      'This corpus contains only document with id=' || NEW.id :: text || '''.',
	       	      current_timestamp,
	       	      current_user,
	       	      current_user,
	       	      292);
	INSERT INTO standoff.corpus_document
	       (corpus, document, created_at, created_by)
	       VALUES (currval('standoff.corpus_id_seq'),
	       	       NEW.id,
		       current_timestamp,
		       current_user);
	RETURN NEW;
	END;
	$$ LANGUAGE plpgsql
        -- Execute this function with the privileges of it's definer
        -- in order to bypass RLS which enforces that corpus_type is
        -- 'collection'.
	SECURITY DEFINER;

CREATE TRIGGER create_document_corpus AFTER INSERT ON standoff.document
       FOR EACH ROW EXECUTE PROCEDURE standoff.create_document_corpus();


-- Trigger for deleting document from all corpora. It is called AFTER
-- DELETE, so that the corpus entry is still there during the deletion
-- of the document's tokens.

CREATE OR REPLACE FUNCTION standoff.delete_document_from_corpus()
       RETURNS TRIGGER AS $$
       DECLARE
       doc_corpus_id integer;
       BEGIN
       SELECT cd.corpus INTO doc_corpus_id
       	      FROM standoff.corpus_document cd, standoff.document d, standoff.corpus c
       	      WHERE c.corpus_type = 'document'
	      AND c.id = cd.corpus
	      AND cd.document = OLD.id;
       DELETE FROM standoff.corpus_document WHERE document = OLD.id;
       DELETE FROM standoff.corpus WHERE id = doc_corpus_id;
       RETURN NULL;
       END;
       $$ LANGUAGE plpgsql
       SECURITY DEFINER;

-- 's' for alphabetical order
CREATE TRIGGER s_delete_document_from_corpus BEFORE DELETE ON standoff.document
       FOR EACH ROW EXECUTE PROCEDURE standoff.delete_document_from_corpus();


-- Trigger for asserting that a document corpus contains only one document

CREATE OR REPLACE FUNCTION standoff.document_corpus_size1()
       RETURNS TRIGGER AS $$
       BEGIN
       IF EXISTS (SELECT cd.*
       	  	  FROM standoff.corpus_document cd, standoff.corpus c
		  WHERE c.corpus_type = 'document'
		  AND c.id = NEW.corpus
		  AND cd.corpus = NEW.corpus)
		  THEN RAISE EXCEPTION 'A corpus of type ''document'' may only contain one document';
       END IF;
       RETURN NEW;
       END;
       $$ LANGUAGE plpgsql;
		  
CREATE TRIGGER document_corpus_size1 BEFORE INSERT ON standoff.corpus_document
       FOR EACH ROW EXECUTE PROCEDURE standoff.document_corpus_size1();


-- Row level security. It is done through standoff.corpus, except that
-- creators of rows in standoff.corpus_document are allow to select.
--
-- FIXME: Something wrong with RLS. Triggers only create corpus, but
-- no corpus documents.
ALTER TABLE standoff.corpus_document ENABLE ROW LEVEL SECURITY;


-- CREATE POLICY debug ON standoff.corpus_document FOR INSERT TO standoffuser
-- WITH CHECK (true);--created_by = current_user OR created_by is null);


-- Allow select to creator of row in corpus_document

CREATE POLICY rowcreator_select ON standoff.corpus_document FOR SELECT
USING (created_by = current_user);

-- Allow select, insert, delete to creator of corpus.
CREATE POLICY creator_select ON standoff.corpus_document FOR SELECT TO standoffuser
USING ((SELECT c.created_by FROM standoff.corpus c WHERE c.id = corpus) = current_user);

CREATE POLICY creator_insert ON standoff.corpus_document FOR INSERT TO standoffuser
WITH CHECK (((SELECT c.privilege FROM standoff.corpus c WHERE c.id = corpus) & 256) = 256
     	    AND (SELECT c.created_by FROM standoff.corpus c WHERE c.id = corpus) = current_user
     	    AND (created_by = current_user OR created_by is null));

CREATE POLICY creator_delete ON standoff.corpus_document FOR DELETE TO standoffuser
USING (((SELECT c.privilege FROM standoff.corpus c WHERE c.id = corpus) & 256) = 256
       AND (SELECT c.created_by FROM standoff.corpus c WHERE c.id = corpus) = current_user);

-- Allow select, insert and delete to group members.
CREATE POLICY group_select ON standoff.corpus_document FOR SELECT TO standoffuser
USING      (((SELECT c.privilege FROM standoff.corpus c WHERE c.id = corpus) & 64) = 64
            AND pg_has_role((SELECT c.gid FROM standoff.corpus c WHERE c.id = corpus),
	    		    'MEMBER'));

CREATE POLICY group_insert ON standoff.corpus_document FOR INSERT TO standoffuser
WITH CHECK (((SELECT c.privilege FROM standoff.corpus c WHERE c.id = corpus) & 32) = 32
            AND pg_has_role((SELECT c.gid FROM standoff.corpus c WHERE c.id = corpus),
	    		    'MEMBER')
	    AND (created_by = current_user OR created_by is null));

CREATE POLICY group_delete ON standoff.corpus_document FOR DELETE TO standoffuser
USING      (((SELECT c.privilege FROM standoff.corpus c WHERE c.id = corpus) & 32) = 32
            AND pg_has_role((SELECT c.gid FROM standoff.corpus c WHERE c.id = corpus),
	    		    'MEMBER'));

-- Allow select, insert and delete to other users.
CREATE POLICY others_select ON standoff.corpus_document FOR SELECT TO standoffuser
USING      (((SELECT c.privilege FROM standoff.corpus c WHERE c.id = corpus) & 4) = 4
            AND pg_has_role((SELECT c.gid FROM standoff.corpus c WHERE c.id = corpus),
	    		    'MEMBER'));

CREATE POLICY others_insert ON standoff.corpus_document FOR INSERT TO standoffuser
WITH CHECK (((SELECT c.privilege FROM standoff.corpus c WHERE c.id = corpus) & 2) = 2
            AND pg_has_role((SELECT c.gid FROM standoff.corpus c WHERE c.id = corpus),
	    		    'MEMBER')
	    AND (created_by = current_user OR created_by is null));

CREATE POLICY others_delete ON standoff.corpus_document FOR DELETE TO standoffuser
USING      (((SELECT c.privilege FROM standoff.corpus c WHERE c.id = corpus) & 2) = 2
            AND pg_has_role((SELECT c.gid FROM standoff.corpus c WHERE c.id = corpus),
	    		    'MEMBER'));


-- Grant select, insert, delete to editor.
CREATE POLICY standoffeditor_all ON standoff.corpus_document FOR ALL TO standoffeditor
USING (true)
WITH CHECK (created_by is null OR created_by = current_user);

COMMIT;
