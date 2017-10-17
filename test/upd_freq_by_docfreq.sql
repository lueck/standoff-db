-- Start transaction and plan the tests
BEGIN;
SELECT plan(61);

-- Configure 'token' as update methods for token frequencies.
CREATE OR REPLACE FUNCTION standoff.frequency_update_method()
       RETURNS varchar(50)
       AS 'SELECT ''token_frequency''::varchar(50);'
       LANGUAGE SQL
       IMMUTABLE;

SELECT lives_ok('INSERT INTO standoff.mimetype (mimetype) VALUES 
       			(''text/plaintext'')
			ON CONFLICT DO NOTHING');

SET ROLE standoffeditor;

SELECT lives_ok('INSERT INTO standoff.text_document
       			(mimetype, text) VALUES
			(''text/plaintext'',
			''How$T much$T wood$T could$T a$T woodchuck$T chuck$T If$T a$T woodchuck$T could$T chuck$T wood$T?$T As$T much$T wood$T as$T a$T woodchuck$T could$T chuck$T,$T If$T a$T woodchuck$T could$T chuck$T wood$T.$T'')');

SELECT lives_ok('INSERT INTO standoff.corpus
       			(corpus_type, title) VALUES
       			(''collection'', ''fun@Testing$$'')');

SELECT lives_ok('INSERT INTO standoff.corpus_document
       			(corpus_id, document_id) VALUES
			(currval(''standoff.corpus_corpus_id_seq''),
			 currval(''standoff.document_document_id_seq''))');

SELECT lives_ok('INSERT INTO standoff.token_frequency
       			(corpus_id, frequency, token) VALUES
			(currval(''standoff.corpus_corpus_id_seq'')-1, 1, ''How$T''),
			(currval(''standoff.corpus_corpus_id_seq'')-1, 2, ''much$T''),
			(currval(''standoff.corpus_corpus_id_seq'')-1, 4, ''wood$T''),
			(currval(''standoff.corpus_corpus_id_seq'')-1, 4, ''could$T''),
			(currval(''standoff.corpus_corpus_id_seq'')-1, 4, ''a$T''),
			(currval(''standoff.corpus_corpus_id_seq'')-1, 4, ''woodchuck$T''),
			(currval(''standoff.corpus_corpus_id_seq'')-1, 4, ''chuck$T''),
			(currval(''standoff.corpus_corpus_id_seq'')-1, 2, ''If$T''),
			(currval(''standoff.corpus_corpus_id_seq'')-1, 1, ''AS$T''),
			(currval(''standoff.corpus_corpus_id_seq'')-1, 1, ''as$T''),
			(currval(''standoff.corpus_corpus_id_seq'')-1, 1, ''?$T''),
			(currval(''standoff.corpus_corpus_id_seq'')-1, 1, '',$T''),
			(currval(''standoff.corpus_corpus_id_seq'')-1, 1, ''.$T'')
			');

-- We can not insert frequencies on other corpuses than document
-- corpus types.
SELECT throws_ok('INSERT INTO standoff.token_frequency
       			(corpus_id, frequency, token) VALUES
			(currval(''standoff.corpus_corpus_id_seq''), 1, ''See$T'')'
		, '42501'
		, 'new row violates row-level security policy for table "token_frequency"');


-- count of tokens: 30
SELECT is(c.tokens, 30) FROM standoff.corpus c, standoff.corpus_document cd
       WHERE cd.document_id = currval('standoff.document_document_id_seq')
       AND c.corpus_id = cd.corpus_id
       AND c.corpus_type = 'document';
SELECT is(sum(tf.frequency)::integer, 30)
       FROM standoff.token_frequency tf
       LEFT JOIN standoff.corpus c USING (corpus_id)
       WHERE c.corpus_type = 'document'
       AND c.title = 'Document corpus ' || currval('standoff.document_document_id_seq') :: text;
SELECT is(c.tokens, 30) FROM standoff.corpus c, standoff.corpus_document cd
       WHERE c.title = 'fun@Testing$$';

-- count of tokens deduplicated:
SELECT is(c.tokens_dedupl, 13) FROM standoff.corpus c, standoff.corpus_document cd
       WHERE cd.document_id = currval('standoff.document_document_id_seq')
       AND c.corpus_id = cd.corpus_id
       AND c.corpus_type = 'document';
SELECT is(count(*)::integer, 13)
       FROM standoff.token_frequency tf
       LEFT JOIN standoff.corpus c USING (corpus_id)
       WHERE c.corpus_type = 'document'
       AND c.title = 'Document corpus ' || currval('standoff.document_document_id_seq') :: text;
SELECT is(c.tokens_dedupl, 13) FROM standoff.corpus c, standoff.corpus_document cd
       WHERE c.title = 'fun@Testing$$';

-- frequency of 'woodchuck$T': 4 in global corpus
SELECT is(tf.frequency, 4)
       FROM standoff.token_frequency tf
       JOIN standoff.corpus c USING (corpus_id)
       WHERE tf.token = 'woodchuck$T'
       AND c.corpus_type = 'global';

-- frequency of 'as$T' equals 1 in 3 corpora
SELECT is(count(*)::integer, 3) FROM standoff.token_frequency tf
       WHERE tf.token = 'as$T' AND tf.frequency = 1;

-- frequency of '?$T': 1 in each corpus having it.
SELECT is(tf.frequency, 1) FROM standoff.token_frequency tf
       WHERE tf.token = '?$T';


-- increment sequences in transaction
SELECT nextval('standoff.document_document_id_seq');
SELECT nextval('standoff.corpus_corpus_id_seq');


-- An other document
SELECT lives_ok('INSERT INTO standoff.text_document
       			(mimetype, text) VALUES
			(''text/plaintext'',
			''the$T woodchuck$T lives$T in$T a$T wood$T.$T'')');

SELECT lives_ok('INSERT INTO standoff.token_frequency
       			(corpus_id, frequency, token) VALUES
			(currval(''standoff.corpus_corpus_id_seq''), 1, ''the$T''),
			(currval(''standoff.corpus_corpus_id_seq''), 1, ''woodchuck$T''),
			(currval(''standoff.corpus_corpus_id_seq''), 1, ''lives$T''),
			(currval(''standoff.corpus_corpus_id_seq''), 1, ''in$T''),
			(currval(''standoff.corpus_corpus_id_seq''), 1, ''a$T''),
			(currval(''standoff.corpus_corpus_id_seq''), 1, ''wood$T''),
			(currval(''standoff.corpus_corpus_id_seq''), 1, ''.$T'')
			');

SELECT is(count(*)::integer, 7)
       FROM standoff.token_frequency tf
       LEFT JOIN standoff.corpus c USING (corpus_id)
       WHERE c.corpus_type = 'document'
       AND c.title = 'Document corpus ' || currval('standoff.document_document_id_seq') :: text;

SELECT is(tf.frequency, 5) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'a$T'
       AND tf.corpus_id = c.corpus_id
       AND c.corpus_type = 'global';

SELECT is(tf.frequency, 5) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'woodchuck$T'
       AND tf.corpus_id = c.corpus_id
       AND c.corpus_type = 'global';

SELECT is(tf.frequency, 2) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = '.$T'
       AND tf.corpus_id = c.corpus_id
       AND c.corpus_type = 'global';

-- frequency of 'a$T' equals 4 in fun@Testing$$ corpus.
SELECT is(tf.frequency, 4) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'a$T'
       AND tf.corpus_id = c.corpus_id
       AND c.title = 'fun@Testing$$';

-- add second document to corpus 'fun@Testing$$'
SELECT lives_ok('INSERT INTO standoff.corpus_document
       (corpus_id, document_id) VALUES
       ((SELECT c.corpus_id FROM standoff.corpus c WHERE c.title = ''fun@Testing$$''),
       	currval(''standoff.document_document_id_seq''))');

-- still the same frequencies in global corpus
SELECT is(tf.frequency, 5) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'a$T'
       AND tf.corpus_id = c.corpus_id
       AND c.corpus_type = 'global';
SELECT is(tf.frequency, 5) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'woodchuck$T'
       AND tf.corpus_id = c.corpus_id
       AND c.corpus_type = 'global';

-- frequency of 'a$T' now equals 5 in corpus 'fun@Testing$$'.
SELECT is(tf.frequency, 5) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'a$T'
       AND tf.corpus_id = c.corpus_id
       AND c.title = 'fun@Testing$$';

-- 30+7 tokens in corpus 'fun@Testing$$'.
SELECT is(c.tokens, 37) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';

-- How many different tokens are there in corpus 'fun@Testing$$'?
SELECT is(count(*)::integer, 16) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.corpus_id = c.corpus_id
       AND c.title = 'fun@Testing$$';

-- How many different tokens are there in corpus 'fun@Testing$$'?
SELECT is(c.tokens_dedupl, 16) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';


-- delete second document from corpus 'fun@Testing$$'
SELECT lives_ok('DELETE FROM standoff.corpus_document
       			WHERE document_id = currval(''standoff.document_document_id_seq'')
			AND corpus_id = (SELECT corpus_id FROM standoff.corpus
			    	      	 WHERE title = ''fun@Testing$$'')');

-- frequency of 'a$T' now again equals 4 in corpus 'fun@Testing$$'.
SELECT is(tf.frequency, 4) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'a$T'
       AND tf.corpus_id = c.corpus_id
       AND c.title = 'fun@Testing$$';

-- count of tokens in corpus 'fun@Testing$$' now again equals 10.
SELECT is(c.tokens, 30) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';

-- How many different tokens are there in corpus 'fun@Testing$$'?
SELECT is(c.tokens_dedupl, 13) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';
SELECT is(count(*)::integer, 13) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.corpus_id = c.corpus_id
       AND c.title = 'fun@Testing$$';

-- frequency of 'woodchuck$T' in global corpus?
SELECT is(tf.frequency, 5) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'woodchuck$T'
       AND tf.corpus_id = c.corpus_id
       AND c.corpus_type = 'global';


-- delete one of the second document's token_frequency entry
RESET ROLE; -- deletion of single token_frequency rows is not
	    -- allowed. But the database is kept in a consistent
	    -- state, if the definer does.
SELECT lives_ok('DELETE FROM standoff.token_frequency
       			WHERE token = ''woodchuck$T''
			AND corpus_id = (SELECT c.corpus_id
			    	         FROM standoff.token_frequency tf, standoff.corpus c
			    	         WHERE c.corpus_type = ''document''
					 AND c.corpus_id = tf.corpus_id
					 AND tf.token = ''lives$T'')');

SET ROLE standoffeditor;

-- frequency of 'woodchuck$T' equals 4 in global corpus.
SELECT is(tf.frequency, 4) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'woodchuck$T'
       AND tf.corpus_id = c.corpus_id
       AND c.corpus_type = 'global';

-- tokens and tokens_dedupl in document corpus
SELECT is(c.tokens, 6)
       FROM standoff.corpus c
       WHERE corpus_id = (SELECT c.corpus_id
		          FROM standoff.token_frequency tf, standoff.corpus c
			  WHERE c.corpus_type = 'document'
			  AND c.corpus_id = tf.corpus_id
			  AND tf.token = 'lives$T');
SELECT is(c.tokens, 6)
       FROM standoff.corpus c
       WHERE corpus_id = (SELECT c.corpus_id
		          FROM standoff.token_frequency tf, standoff.corpus c
			  WHERE c.corpus_type = 'document'
			  AND c.corpus_id = tf.corpus_id
			  AND tf.token = 'lives$T');

-- frequency of 'woodchuck$T' sill equals 4 in corpus 'fun@Testing$$'.
SELECT is(tf.frequency, 4) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'woodchuck$T'
       AND tf.corpus_id = c.corpus_id
       AND c.title = 'fun@Testing$$';

-- count of tokens in corpus 'fun@Testing$$' still equals 10.
SELECT is(c.tokens, 30) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';

-- How many different tokens are there in corpus 'fun@Testing$$'?
SELECT is(count(*)::integer, 13) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.corpus_id = c.corpus_id
       AND c.title = 'fun@Testing$$';

SELECT is(c.tokens_dedupl, 13) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';



SELECT lives_ok('DELETE FROM standoff.document WHERE document_id = currval(''standoff.document_document_id_seq'')');

-- token X in how many corpusus?
SELECT is(count(*)::integer, 3) FROM standoff.token_frequency tf
       WHERE tf.token = 'woodchuck$T';
SELECT is(count(*)::integer, 0) FROM standoff.token_frequency tf
       WHERE tf.token = 'lives$T';
SELECT is(standoff.corpus_get_corpus_type(corpus_id), NULL)
       FROM standoff.token_frequency tf
       WHERE tf.token = 'lives$T';


-- deletion of a document should result in cascading deletion of its tokens.
SELECT lives_ok('DELETE FROM standoff.document WHERE document_id =
       			(SELECT cd.document_id
			 FROM standoff.corpus_document cd, standoff.corpus c
			 WHERE c.title = ''fun@Testing$$''
			 AND c.corpus_id = cd.corpus_id)');

SELECT is(count(*)::integer, 0) FROM standoff.token_frequency tf
       WHERE tf.token = 'woodchuck$T';
SELECT is(count(*)::integer, 0) FROM standoff.token_frequency tf
       WHERE tf.token = 'lives$T';
SELECT is(count(*)::integer, 0) FROM standoff.token_frequency tf
       WHERE tf.token = 'could$T';


-- count of tokens in corpus 'fun@Testing$$' now again equals 0.
SELECT is(c.tokens, 0) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';
SELECT is(c.tokens_dedupl, 0) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';
SELECT is(sum(tf.frequency), NULL) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.corpus_id = c.corpus_id
       AND c.title = 'fun@Testing$$';

-- How many different tokens are there in corpus 'fun@Testing$$'?
SELECT is(count(tf.*)::integer, 0) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.corpus_id = c.corpus_id
       AND c.title = 'fun@Testing$$';

SELECT is(c.tokens_dedupl, 0) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';


-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
