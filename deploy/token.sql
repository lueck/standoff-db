-- Deploy token
-- requires: document
-- requires: arbschema
-- requires: arbroles
-- requires: vocabulary

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.token (
       token_number integer not null, -- part of the PK, set by application
       token text not null,     -- word form
       --sentence_number integer, -- reference (part) to sentence
       token_int integer null,  -- integer representation, not the primary key!
       sentence integer,        -- number of sentence (or other primary segementation)
       number_in_sentence integer,   -- number in sentence
       lemma text,              -- normalized word form
       postag text,             -- Part of Speach tag
       tagset text,             -- Tagset, where the POStag is selected from
       PRIMARY KEY (document_id, token_number),
       -- FOREIGN KEY  (document_id, sentence_number) REFERENCES standoff.sentence (document_id, sentence_number)
       FOREIGN KEY (token_int) REFERENCES standoff.vocabulary(token_int)
       )
       INHERITS (standoff.document_range);

-- Insertion, update and deletion of tokens is a very sensitive
-- task. We only allow it to editors and admins. In a database where
-- signup is open to the world and everyone can become a standoffuser,
-- every one could sabotage text mining by adding arbitrary tokens if
-- insertion was allowed to normal users.

GRANT SELECT ON TABLE standoff.token TO standoffuser;

GRANT SELECT, INSERT, DELETE, UPDATE ON TABLE standoff.token TO standoffeditor, standoffadmin;


-- -- Deletion is done by triggers, not by cascading deletion on deletion
-- -- of the document. Reason: Triggers allow us to determine the order
-- -- of deletion with regard to other deletions or frequency
-- -- decrementations.
-- CREATE OR REPLACE FUNCTION standoff.delete_token()
--        RETURNS TRIGGER AS $$
--        BEGIN
--        DELETE FROM standoff.token
--        WHERE document_id = OLD.document_id;
--        RETURN OLD;
--        END;
--        $$ LANGUAGE plpgsql
--        SECURITY DEFINER;

-- CREATE TRIGGER delete_on_document_delete BEFORE DELETE ON standoff.document
--        FOR EACH ROW EXECUTE PROCEDURE standoff.delete_token();

COMMIT;
