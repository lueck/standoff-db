-- Deploy upd_freq_by_docfreq
-- requires: corpus_document
-- requires: token_frequency
-- requires: frequency_update_method

BEGIN;

-- Configure the update method for token frequencies. If
-- standoff.frequency_update_method returns 'token_frequency', then
-- the triggers in this file will take effect.
-- CREATE OR REPLACE FUNCTION standoff.frequency_update_method
--        RETURNS varchar
--        AS 'SELECT ''token_frequency'';'
--        LANGUAGE SQL
--        IMMUTABLE;

-- Add the frequency of a token to a corpus.
CREATE OR REPLACE FUNCTION standoff.add_token_frequency_to_corpus (corps integer, tok text, freq integer)
       RETURNS void AS $$
       BEGIN
       -- Update token_dedupl where token is still missing.
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
       	      SELECT corps, tok -- frequency set to 0 here, updated later
       	      WHERE NOT EXISTS
	      (SELECT *
       	       FROM standoff.token_frequency tf
	       WHERE tf.token = tok    -- token not already present
	       AND tf.corpus_id = corps); -- in corpus
       -- Update the count of tokens in each corpus.
       UPDATE standoff.corpus
	      SET tokens = tokens + freq
	      WHERE corpus_id = corps;
       -- Update the frequency of the token in each corpus.
       UPDATE standoff.token_frequency
	      SET frequency = frequency + freq
	      WHERE token = tok
	      AND corpus_id = corps;
       END;
       $$ LANGUAGE 'plpgsql'
       SECURITY DEFINER;

-- Add the frequency of a token in a document corpus to each corpus
-- where in the document is registered in.
CREATE OR REPLACE FUNCTION standoff.add_token_frequency_each_corpus (doc integer, tok text, freq integer)
    RETURNS void AS $$
    DECLARE
	corps integer;
    BEGIN
    FOR corps IN SELECT cd.corpus_id
    	      	 FROM standoff.corpus_document cd
		 LEFT JOIN standoff.corpus c USING (corpus_id)
    		 WHERE cd.document_id = doc
		 AND c.corpus_type <> 'document'
	LOOP
	PERFORM standoff.add_token_frequency_to_corpus(corps, tok, freq);
    	END LOOP;
    END;
    $$ LANGUAGE 'plpgsql'
    SECURITY DEFINER;

-- Update the frequency in non-document corpuses after insertion
CREATE OR REPLACE FUNCTION standoff.add_token_frequency_on_frequency_insert ()
       RETURNS TRIGGER AS $$
       BEGIN
       PERFORM standoff.add_token_frequency_each_corpus
       	       ((SELECT document_id
       	       		FROM standoff.corpus_document
       			WHERE corpus_id = NEW.corpus_id),
       		NEW.token, NEW.frequency);
       -- -- alternative with better function, syntax error, fixme:
       -- DECLARE
       -- 	corps integer;
       -- 	doc integer;
       -- BEGIN
       -- SELECT document_id
       -- 	      FROM standoff.corpus_document cd, standoff.corpus c
       -- 	      WHERE cd.corpus_id = NEW.corpus_id
       -- 	      AND c.corpus_id = cd.corpus_id
       -- 	      AND c.corpus_type = 'document'
       -- 	      INTO doc;
       -- FOR corps IN SELECT cd.corpus_id
       -- 	      	 FROM standoff.corpus_document cd, standoff.corpus c
       -- 		 WHERE cd.document_id = (SELECT document_id
       -- 		 	      FROM standoff.corpus_document cd, standoff.corpus c
       -- 	      		      WHERE cd.corpus_id = NEW.corpus_id
       -- 	      		      AND c.corpus_id = cd.corpus_id
       -- 	      		      AND c.corpus_type = 'document')
       -- 		 AND c.corpus_id = cd.corpus_id
       -- 		 AND c.corpus_type <> 'document'
       --     LOOP
       -- 		PERFORM standoff.add_token_frequency_to_corpus
       -- 			(corps, NEW.token, NEW.frequency);
       -- 	   END LOOP;
       UPDATE standoff.corpus
       	      SET tokens = tokens + NEW.frequency, tokens_dedupl = tokens_dedupl + 1
	      WHERE corpus_id = NEW.corpus_id;
       RETURN NEW;
       END;
       $$ LANGUAGE 'plpgsql'
       SECURITY DEFINER;

CREATE TRIGGER add_token_frequency
       AFTER INSERT ON standoff.token_frequency
       FOR EACH ROW
       WHEN (standoff.frequency_update_method() = 'token_frequency'
       	     AND standoff.corpus_get_corpus_type(NEW.corpus_id) = 'document')
       EXECUTE PROCEDURE standoff.add_token_frequency_on_frequency_insert();

-- Update token frequencies after insertion of a document into a corpus.
CREATE OR REPLACE FUNCTION standoff.add_token_frequency_on_corpus_document_insert ()
       RETURNS TRIGGER AS $$
       DECLARE
           tok text;
	   freq integer;
       BEGIN
       FOR tok, freq IN SELECT tf.token, tf.frequency
       	   	     	FROM standoff.token_frequency tf, standoff.corpus_document cd, standoff.corpus c
			WHERE tf.corpus_id = cd.corpus_id
			AND tf.corpus_id = c.corpus_id
			AND c.corpus_type = 'document'
			AND cd.document_id = NEW.document_id
           LOOP
	   PERFORM standoff.add_token_frequency_to_corpus
	   	   (NEW.corpus_id::integer, tok, freq);
	   END LOOP;
       RETURN NEW;
       END;
       $$ LANGUAGE 'plpgsql'
       SECURITY DEFINER;

CREATE TRIGGER add_token_frequency
       AFTER INSERT ON standoff.corpus_document
       FOR EACH ROW
       WHEN (standoff.frequency_update_method() = 'token_frequency')
       EXECUTE PROCEDURE standoff.add_token_frequency_on_corpus_document_insert();


-- Substract the frequency of a token in a document corpus from each
-- corpus, in which the document is registered.
CREATE OR REPLACE FUNCTION standoff.substract_token_frequency_each_corpus(doc integer, tok text, freq integer)
       RETURNS void AS $$
       DECLARE
       corps integer;
       BEGIN
       -- Select the appropriate corpora and ...
       FOR corps IN SELECT cd.corpus_id
    	      	    FROM standoff.corpus_document cd
		    LEFT JOIN standoff.corpus c USING (corpus_id)
    		    WHERE cd.document_id = doc
		    AND c.corpus_type <> 'document'
		 LOOP
		    -- RAISE NOTICE '    substracting % for token % on corpus %', freq, tok, corps;
		    -- reduce the overall count of tokens in each corpus by freq.
		    UPDATE standoff.corpus
		    	   SET tokens = tokens - freq
		    	   WHERE corpus_id = corps;
		    -- reduce the frequency of the token in each corpus by freq.
		    UPDATE standoff.token_frequency
		    	   SET frequency = frequency - freq
			   WHERE token = tok
			   AND corpus_id = corps;
		    -- Decrement token_dedupl if frequency equals 0 now.
		    UPDATE standoff.corpus
		    	   SET tokens_dedupl = tokens_dedupl - 1
			   WHERE corpus_id = corps
			   AND 0 = (SELECT tf.frequency
       	     	    	       	    FROM standoff.token_frequency tf
	     	    	    	    WHERE tf.token = tok
				    AND tf.frequency = 0     -- token not present any more
			    	    AND tf.corpus_id = corps); -- in corpus
       END LOOP;
       -- delete token where it's frequency equals 0.
       DELETE FROM standoff.token_frequency WHERE frequency = 0;
       END;
       $$ 
       LANGUAGE plpgsql;

-- Substract the frequency of a token in a document corpus from each
-- corpus, in which the document is registered.
CREATE OR REPLACE FUNCTION standoff.substract_token_frequency_from_corpus(corps integer, tok text, freq integer)
       RETURNS void AS $$
       BEGIN
       -- RAISE NOTICE '    substracting for corpus %', corps;
       -- reduce the overall count of tokens in each corpus by freq.
       UPDATE standoff.corpus
       	      SET tokens = tokens - freq
	      WHERE corpus_id = corps;
       -- reduce the frequency of the token in each corpus by freq.
       UPDATE standoff.token_frequency
       	      SET frequency = frequency - freq
	      WHERE token = tok
	      AND corpus_id = corps;
       -- Decrement token_dedupl if frequency equals 0 now.
       UPDATE standoff.corpus
       	      SET tokens_dedupl = tokens_dedupl - 1
	      WHERE corpus_id = corps
	      AND 0 = (SELECT tf.frequency
       	      	       FROM standoff.token_frequency tf
	     	       WHERE tf.token = tok
		       AND tf.frequency = 0     -- token not present any more
		       AND tf.corpus_id = corps); -- in corpus
       -- delete token where it's frequency equals 0.
       DELETE FROM standoff.token_frequency WHERE frequency = 0;
       END;
       $$ 
       LANGUAGE plpgsql;

-- Decrement the frequency of a token on deletion of a token from
-- standoff.token.
CREATE OR REPLACE FUNCTION standoff.substract_token_frequency_on_token_frequency_delete()
       RETURNS TRIGGER AS $$
       BEGIN
       -- RAISE NOTICE 'substract trigger fired on deletion of token_frequency'; 
       PERFORM standoff.substract_token_frequency_each_corpus
       	       ((SELECT document_id
	       		FROM standoff.corpus_document
			WHERE corpus_id = OLD.corpus_id),
		OLD.token, OLD.frequency);
       -- update tokens and tokens_dedupl in document corpus
       UPDATE standoff.corpus
       	      SET tokens = tokens - OLD.frequency,
	      	  tokens_dedupl = tokens_dedupl - 1
	      WHERE corpus_id = OLD.corpus_id;
       RETURN OLD;
       END;
       $$ LANGUAGE plpgsql
       SECURITY DEFINER;

CREATE TRIGGER substract_token_frequency
       BEFORE DELETE ON standoff.token_frequency
       FOR EACH ROW
       WHEN (standoff.frequency_update_method() = 'token_frequency'
       	     AND standoff.corpus_get_corpus_type(OLD.corpus_id) = 'document')
       EXECUTE PROCEDURE standoff.substract_token_frequency_on_token_frequency_delete();


-- Substract the frequency of a token on deregistering a document from
-- a corpus, i.e. deletion from standoff.corpus_document.
CREATE OR REPLACE FUNCTION standoff.substract_token_frequency_on_corpus_document_delete()
       RETURNS TRIGGER AS $$
       DECLARE
       tok text;
       freq integer;
       BEGIN
       -- RAISE NOTICE 'substract trigger fired on deletion of corpus_document % %. tokens: %, corpsdocs: %', OLD.corpus_id, OLD.document_id, (SELECT count(*) FROM standoff.token_frequency), (SELECT count(*) FROM standoff.corpus_document WHERE standoff.corpus_get_corpus_type(corpus_id) = 'document');
       -- TODO: for loop not run for 'collection' corpus type
       FOR tok, freq IN SELECT tf.token, tf.frequency
       	   	     	       FROM standoff.token_frequency tf, standoff.corpus_document cd, standoff.corpus c
       	   	     	       WHERE tf.corpus_id = cd.corpus_id
			       AND cd.document_id = OLD.document_id
			       AND tf.corpus_id = c.corpus_id
			       AND c.corpus_type = 'document'
		     LOOP
			-- RAISE NOTICE ' calling substract % % %', OLD.corpus_id, tok, freq; 
			PERFORM standoff.substract_token_frequency_from_corpus
				(OLD.corpus_id, tok, freq);
       END LOOP;
       RETURN OLD;
       END;
       $$ LANGUAGE plpgsql
       SECURITY DEFINER;

CREATE TRIGGER d30_substract_token_frequency
       BEFORE DELETE ON standoff.corpus_document
       FOR EACH ROW
       WHEN (standoff.frequency_update_method() = 'token_frequency'
       	     AND standoff.corpus_get_corpus_type(OLD.corpus_id) <> 'document')
       EXECUTE PROCEDURE standoff.substract_token_frequency_on_corpus_document_delete();


COMMIT;
