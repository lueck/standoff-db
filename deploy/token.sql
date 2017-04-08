-- Deploy token
-- requires: document
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.token (
       document integer not null references standoff.document, -- part of the PK
       number integer not null, -- part of the PK, set by application
       token text not null,     -- word form
       lemma text,              -- normalized word form
       source_start integer,    -- start character offset regarding the document source
       source_end integer,      -- end character offset
       text_start integer,      -- start character offset with regrad to the text layer (cf. TCF)
       text_end integer,        -- end character offset
       PRIMARY KEY (document, number));

-- Insertion, update and deletion of tokens is a very sensitive
-- task. We only allow it to editors and admins. In a database where
-- signup is open to the world and everyone can become a standoffuser,
-- every one could sabotage text mining by adding arbitrary tokens if
-- insertion was allowed to normal users.

GRANT SELECT ON TABLE standoff.token TO standoffuser;

GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE standoff.token TO standoffeditor, standoffadmin;


-- Deletion is done by triggers, not by cascading deletion on deletion
-- of the document. Reason: Triggers allow us to determine the order
-- of deletion with regard to other deletions or frequency
-- decrementations.
CREATE OR REPLACE FUNCTION standoff.delete_token()
       RETURNS TRIGGER AS $$
       BEGIN
       DELETE FROM standoff.token
       WHERE document = OLD.id;
       RETURN OLD;
       END;
       $$ LANGUAGE plpgsql
       SECURITY DEFINER;

CREATE TRIGGER delete_on_document_delete BEFORE DELETE ON standoff.document
       FOR EACH ROW EXECUTE PROCEDURE standoff.delete_token();

COMMIT;
