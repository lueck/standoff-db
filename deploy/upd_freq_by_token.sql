-- Deploy update_token_freq
-- requires: corpus_document
-- requires: token_frequency

BEGIN;

-- Increment the frequency for a token in all corpus the token's
-- document is in. The document's ID and the token must be passed as
-- parameters. The appropriate corpora are concluded from the document
-- ID. If the token is still unknown in one of theses corpora, a new
-- row in token_frequency is created.
CREATE OR REPLACE FUNCTION standoff.inc_token_frequency(doc integer, tok text)
       RETURNS void AS $$
       DECLARE
       corps integer;
       BEGIN
       -- Select the appropriate corpora and ...
       FOR corps IN SELECT cd.corpus_id
       	   	    FROM standoff.corpus_document cd
		    WHERE cd.document_id = doc
		    LOOP
		    -- Increment token_dedupl where token is still
		    -- missing.
		    UPDATE standoff.corpus
		    	   SET tokens_dedupl = tokens_dedupl + 1
			   WHERE corpus_id = corps
			   AND NOT EXISTS
			   (SELECT *
       	     	    	    FROM standoff.token_frequency tf
	     	    	    WHERE tf.token = tok    -- token not already present
			    AND tf.corpus_id = corps); -- in corpus
		    -- Insert token in each corpus where it is still
		    -- missing.
       		    INSERT INTO standoff.token_frequency (corpus_id, token)
       	      	    SELECT corps, tok
       		    WHERE NOT EXISTS
		    	  (SELECT *
       	     	    	   FROM standoff.token_frequency tf
	     	    	   WHERE tf.token = tok    -- token not already present
			   AND tf.corpus_id = corps); -- in corpus
		    -- Increment the count of tokens in each corpus.
		    UPDATE standoff.corpus
		    	   SET tokens = tokens + 1
		    	   WHERE corpus_id = corps;
		    -- Increment the frequency of the token in each corpus.
		    UPDATE standoff.token_frequency
		    	   SET frequency = frequency + 1
			   WHERE token = tok
			   AND corpus_id = corps;
       END LOOP;
       -- -- Increment the frequency of the token in the appropriate corpora.
       -- UPDATE standoff.token_frequency
       -- 	      SET frequency = frequency + 1
       -- 	      WHERE token = tok
       -- 	      AND corpus IN (SELECT cd.corpus_id
       -- 	      	  	     FROM standoff.corpus_document cd
       -- 	     		     WHERE cd.document = doc);
       END;
       $$ 
       LANGUAGE plpgsql;

-- Increment the frequency of a token on insertion of a token to
-- standoff.token.
CREATE OR REPLACE FUNCTION standoff.inc_token_frequency_on_token_insert()
       RETURNS TRIGGER AS $$
       BEGIN
       PERFORM standoff.inc_token_frequency(NEW.document_id::integer, NEW.token);
       RETURN NEW;
       END;
       $$ LANGUAGE plpgsql
       SECURITY DEFINER;

CREATE TRIGGER inc_token_frequency AFTER INSERT ON standoff.token
       FOR EACH ROW EXECUTE PROCEDURE standoff.inc_token_frequency_on_token_insert();


-- Increment the frequency of a token on registering a document in a
-- corpus, i.e. insertion into corpus_document.
CREATE OR REPLACE FUNCTION standoff.inc_token_frequency_on_corpus_document_insert()
       RETURNS TRIGGER AS $$
       DECLARE
       token text;
       BEGIN
       FOR token IN SELECT t.token FROM standoff.token t
       	   	    WHERE t.document_id = NEW.document_id
		 LOOP
		 PERFORM standoff.inc_token_frequency(NEW.document_id, token);
       END LOOP;
       RETURN NEW;
       END;
       $$ LANGUAGE plpgsql
       SECURITY DEFINER;

CREATE TRIGGER inc_token_frequency AFTER INSERT ON standoff.corpus_document
       FOR EACH ROW EXECUTE PROCEDURE standoff.inc_token_frequency_on_corpus_document_insert();


-- Decrement the frequency of a token.
CREATE OR REPLACE FUNCTION standoff.dec_token_frequency(doc integer, tok text)
       RETURNS void AS $$
       DECLARE
       corps integer;
       BEGIN
       -- Select the appropriate corpora and ...
       FOR corps IN SELECT cd.corpus_id
       	   	    FROM standoff.corpus_document cd
		    WHERE cd.document_id = doc
		    LOOP
		    -- decrement the count of tokens in each corpus.
		    UPDATE standoff.corpus
		    	   SET tokens = tokens - 1
		    	   WHERE corpus_id = corps;
		    -- decrement the frequency of the token in each corpus.
		    UPDATE standoff.token_frequency
		    	   SET frequency = frequency - 1
			   WHERE token = tok
			   AND corpus_id = corps;
		    -- Decrement token_dedupl if frequency equals 0 now.
		    UPDATE standoff.corpus
		    	   SET tokens_dedupl = tokens_dedupl - 1
			   WHERE corpus_id = corps
			   AND 0 = (SELECT tf.frequency
       	     	    	       	    FROM standoff.token_frequency tf
	     	    	    	    WHERE tf.frequency = 0     -- token not already present
			    	    AND tf.corpus_id = corps); -- in corpus
       END LOOP;
       -- delete token where it's frequency equals 0.
       DELETE FROM standoff.token_frequency WHERE frequency = 0;
       END;
       $$ 
       LANGUAGE plpgsql;

-- Decrement the frequency of a token on deletion of a token from
-- standoff.token.
CREATE OR REPLACE FUNCTION standoff.dec_token_frequency_on_token_delete()
       RETURNS TRIGGER AS $$
       BEGIN
       PERFORM standoff.dec_token_frequency(OLD.document_id::integer, OLD.token);
       RETURN OLD;
       END;
       $$ LANGUAGE plpgsql
       SECURITY DEFINER;

CREATE TRIGGER dec_token_frequency BEFORE DELETE ON standoff.token
       FOR EACH ROW EXECUTE PROCEDURE standoff.dec_token_frequency_on_token_delete();


-- Decrement the frequency of a token on deregistering a document from
-- a corpus, i.e. deletion from standoff.corpus_document.
CREATE OR REPLACE FUNCTION standoff.dec_token_frequency_on_corpus_document_delete()
       RETURNS TRIGGER AS $$
       DECLARE
       token text;
       BEGIN
       FOR token IN SELECT t.token FROM standoff.token t
       	   	    WHERE t.document_id = OLD.document_id
		 LOOP
		 PERFORM standoff.dec_token_frequency(OLD.document_id, token);
       END LOOP;
       RETURN OLD;
       END;
       $$ LANGUAGE plpgsql
       SECURITY DEFINER;

CREATE TRIGGER dec_token_frequency BEFORE DELETE ON standoff.corpus_document
       FOR EACH ROW EXECUTE PROCEDURE standoff.dec_token_frequency_on_corpus_document_delete();

COMMIT;
