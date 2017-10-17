-- Deploy corpus_document
-- requires: document
-- requires: corpus

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.corpus_document (
       corpus_id integer not null references standoff.corpus,
       document_id integer not null references standoff.document,
       created_at timestamp not null,
       created_by varchar not null,
       -- A unique index on (corpus, document) asserts that documents
       -- are not in a corpus multiple times. It also prevents adding
       -- to the global corpus manually, provided that triggers add it
       -- there on the creation of the document.
       UNIQUE (corpus_id, document_id));

-- We never update rows in this crossing table.
GRANT INSERT, SELECT, DELETE ON TABLE standoff.corpus_document
      TO standoffuser, standoffeditor, standoffadmin;

CREATE TRIGGER set_meta_on_insert BEFORE INSERT ON standoff.corpus_document
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

-- Trigger for adding new document to global corpus.

CREATE OR REPLACE FUNCTION standoff.add_document_to_global_corpus()
       RETURNS TRIGGER AS $$
       BEGIN
       INSERT INTO standoff.corpus_document (document_id, corpus_id, created_at, created_by)
       VALUES (NEW.document_id,
       	       (SELECT corpus_id from standoff.corpus WHERE corpus_type = 'global'),
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
       	       	      'Document corpus ' || NEW.document_id :: text,
	       	      'This corpus contains only document with ID=' || NEW.document_id :: text || '.',
	       	      current_timestamp,
	       	      current_user,
	       	      current_user,
	       	      292);
	INSERT INTO standoff.corpus_document
	       (corpus_id, document_id, created_at, created_by)
	       VALUES (currval('standoff.corpus_corpus_id_seq'),
	       	       NEW.document_id,
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


-- Trigger for deleting document from all corpora.
CREATE OR REPLACE FUNCTION standoff.delete_document_from_corpus()
       RETURNS TRIGGER AS $$
       DECLARE
       doc_corpus_id integer;
       BEGIN
       SELECT cd.corpus_id INTO doc_corpus_id
       	      FROM standoff.corpus_document cd, standoff.document d, standoff.corpus c
       	      WHERE c.corpus_type = 'document'
	      AND c.corpus_id = cd.corpus_id
	      AND cd.document_id = OLD.document_id;
       -- unregister the document from all corpuses except the
       -- document corpus. We need this to be deleted as last one.
       DELETE FROM standoff.corpus_document
       	      WHERE document_id = OLD.document_id
	      AND corpus_id NOT IN (SELECT corpus_id FROM standoff.corpus
	      	  	    	    WHERE corpus_type = 'document');
       -- unregister the document form document corpus and delete the
       -- document corpus.
       DELETE FROM standoff.corpus_document WHERE document_id = OLD.document_id;
       DELETE FROM standoff.corpus WHERE corpus_id = doc_corpus_id;
       RETURN OLD;
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
		  AND c.corpus_id = NEW.corpus_id
		  AND cd.corpus_id = NEW.corpus_id)
		  THEN RAISE EXCEPTION 'A corpus of type ''document'' may only contain one document';
       END IF;
       RETURN NEW;
       END;
       $$ LANGUAGE plpgsql;
		  
CREATE TRIGGER document_corpus_size1 BEFORE INSERT ON standoff.corpus_document
       FOR EACH ROW EXECUTE PROCEDURE standoff.document_corpus_size1();


-- Row level security. It is done through standoff.corpus, except that
-- creators of rows in standoff.corpus_document are allowed to select.
ALTER TABLE standoff.corpus_document ENABLE ROW LEVEL SECURITY;

-- Note: We have to use the getter functions for columns of a corpus,
-- because subqueries cause name conflicts: (SELECT c.corpus_type FROM
-- standoff.corpus c WHERE c.corpus_id = corpus_id). How could these
-- name conflicts be resolved, if there is no NEW, OLD or ROW keyword?

-- Allow select on global corpus
CREATE POLICY select_global_corpus ON standoff.corpus_document FOR SELECT
USING (standoff.corpus_get_corpus_type(corpus_id) = 'global'::standoff.corpus_types);

-- Allow select on all document corpora
CREATE POLICY select_document_corpus ON standoff.corpus_document FOR SELECT
USING (standoff.corpus_get_corpus_type(corpus_id) = 'document'::standoff.corpus_types);

-- Allow select to creator of row in corpus_document
CREATE POLICY rowcreator_select ON standoff.corpus_document FOR SELECT
USING (created_by = current_user);

-- Allow select, insert, delete to creator of corpus.
CREATE POLICY creator_select ON standoff.corpus_document FOR SELECT TO standoffuser
USING (standoff.corpus_get_created_by(corpus_id) = current_user);

CREATE POLICY creator_insert ON standoff.corpus_document FOR INSERT TO standoffuser
WITH CHECK ((standoff.corpus_get_privilege(corpus_id) & 64) = 64
     	    AND standoff.corpus_get_created_by(corpus_id) = current_user
     	    AND (created_by = current_user OR created_by is null));

CREATE POLICY creator_delete ON standoff.corpus_document FOR DELETE TO standoffuser
USING ((standoff.corpus_get_privilege(corpus_id) & 64) = 64
       AND standoff.corpus_get_created_by(corpus_id) = current_user);

-- Allow select, insert and delete to group members.
CREATE POLICY group_select ON standoff.corpus_document FOR SELECT TO standoffuser
USING      ((standoff.corpus_get_privilege(corpus_id) & 32) = 32
            AND pg_has_role(standoff.corpus_get_gid(corpus_id),
	    		    'MEMBER'));

CREATE POLICY group_insert ON standoff.corpus_document FOR INSERT TO standoffuser
WITH CHECK ((standoff.corpus_get_privilege(corpus_id) & 8) = 8
            AND pg_has_role(standoff.corpus_get_gid(corpus_id),
	    		    'MEMBER')
	    AND (created_by = current_user OR created_by is null));

CREATE POLICY group_delete ON standoff.corpus_document FOR DELETE TO standoffuser
USING      ((standoff.corpus_get_privilege(corpus_id) & 8) = 8
            AND pg_has_role(standoff.corpus_get_gid(corpus_id),
	    		    'MEMBER'));

-- Allow select, insert and delete to other users.
CREATE POLICY others_select ON standoff.corpus_document FOR SELECT TO standoffuser
USING      ((standoff.corpus_get_privilege(corpus_id) & 4) = 4);

CREATE POLICY others_insert ON standoff.corpus_document FOR INSERT TO standoffuser
WITH CHECK ((standoff.corpus_get_privilege(corpus_id) & 1) = 1
	    AND (created_by = current_user OR created_by is null));

CREATE POLICY others_delete ON standoff.corpus_document FOR DELETE TO standoffuser
USING      ((standoff.corpus_get_privilege(corpus_id) & 1) = 1);


-- Grant select, insert, delete to editor.
CREATE POLICY standoffeditor_all ON standoff.corpus_document FOR ALL TO standoffeditor
USING (true)
WITH CHECK (created_by is null OR created_by = current_user);

COMMIT;
