-- Start transaction and plan the tests
BEGIN;
SELECT plan(35);

SELECT lives_ok('INSERT INTO standoff.mimetype (id) VALUES 
       			(''text/plaintext'')
			ON CONFLICT DO NOTHING');

SET ROLE standoffeditor;

SELECT lives_ok('INSERT INTO standoff.text_document
       			(mimetype, text) VALUES
			(''text/plaintext'',
			''the$T quick$T brown$T fox$T jumps$T over$T the$T lazy$T dog$T.$T'')');

SELECT lives_ok('INSERT INTO standoff.corpus
       			(corpus_type, title) VALUES
       			(''collection'', ''fun@Testing$$'')');

SELECT lives_ok('INSERT INTO standoff.corpus_document
       			(corpus, document) VALUES
			(currval(''standoff.corpus_id_seq''),
			 currval(''standoff.document_id_seq''))');

SELECT lives_ok('INSERT INTO standoff.token
       			(document, number, token) VALUES
			(currval(''standoff.document_id_seq''), 1, ''the$T''),
			(currval(''standoff.document_id_seq''), 2, ''quick$T''),
			(currval(''standoff.document_id_seq''), 3, ''brown$T''),
			(currval(''standoff.document_id_seq''), 4, ''fox$T''),
			(currval(''standoff.document_id_seq''), 5, ''jumps$T''),
			(currval(''standoff.document_id_seq''), 6, ''over$T''),
			(currval(''standoff.document_id_seq''), 7, ''the$T''),
			(currval(''standoff.document_id_seq''), 8, ''lazy$T''),
			(currval(''standoff.document_id_seq''), 9, ''dog$T''),
			(currval(''standoff.document_id_seq''), 10, ''.$T'')
			');

-- count of tokens: 10
SELECT is(c.tokens, 10) FROM standoff.corpus c, standoff.corpus_document cd
       WHERE cd.document = currval('standoff.document_id_seq')
       AND c.id = cd.corpus
       AND c.corpus_type = 'document';
SELECT is(c.tokens, 10) FROM standoff.corpus c, standoff.corpus_document cd
       WHERE c.title = 'fun@Testing$$';

-- frequency of 'the$T': 2
SELECT is(tf.frequency, 2) FROM standoff.token_frequency tf
       WHERE tf.token = 'the$T';

-- frequency of 'the$T' equals 2 in 3 corpora
SELECT is(count(*)::integer, 3) FROM standoff.token_frequency tf
       WHERE tf.token = 'the$T' AND tf.frequency = 2;

-- frequency of 'lazy$T': 1
SELECT is(tf.frequency, 1) FROM standoff.token_frequency tf
       WHERE tf.token = 'lazy$T';


-- increment sequences in transaction
SELECT nextval('standoff.document_id_seq');
SELECT nextval('standoff.corpus_id_seq');


-- An other document
SELECT lives_ok('INSERT INTO standoff.text_document
       			(mimetype, text) VALUES
			(''text/plaintext'',
			''the$T blue$T house$T looks$T at$T the$T blue$T sea.$T'')');

SELECT lives_ok('INSERT INTO standoff.token
       			(document, number, token) VALUES
			(currval(''standoff.document_id_seq''), 1, ''the$T''),
			(currval(''standoff.document_id_seq''), 2, ''blue$T''),
			(currval(''standoff.document_id_seq''), 3, ''house$T''),
			(currval(''standoff.document_id_seq''), 4, ''looks$T''),
			(currval(''standoff.document_id_seq''), 5, ''at$T''),
			(currval(''standoff.document_id_seq''), 6, ''the$T''),
			(currval(''standoff.document_id_seq''), 7, ''blue$T''),
			(currval(''standoff.document_id_seq''), 8, ''sea$T''),
			(currval(''standoff.document_id_seq''), 9, ''.$T'')
			');

SELECT is(tf.frequency, 4) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'the$T'
       AND tf.corpus = c.id
       AND c.corpus_type = 'global';

SELECT is(tf.frequency, 2) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = '.$T'
       AND tf.corpus = c.id
       AND c.corpus_type = 'global';

-- frequency of 'the$T' equals 2 in fun@Testing$$ corpus.
SELECT is(tf.frequency, 2) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'the$T'
       AND tf.corpus = c.id
       AND c.title = 'fun@Testing$$';

-- add second document to corpus 'fun@Testing$$'
SELECT lives_ok('INSERT INTO standoff.corpus_document
       (corpus, document) VALUES
       ((SELECT c.id FROM standoff.corpus c WHERE c.title = ''fun@Testing$$''),
       	currval(''standoff.document_id_seq''))');

-- frequency of 'the$T' now equals 4 in corpus 'fun@Testing$$'.
SELECT is(tf.frequency, 4) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'the$T'
       AND tf.corpus = c.id
       AND c.title = 'fun@Testing$$';

-- frequency of 'the$T' now equals 4 in corpus 'fun@Testing$$'.
SELECT is(c.tokens, 19) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';

-- How many different tokens are there in corpus 'fun@Testing$$'?
SELECT is(count(*)::integer, 14) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.corpus = c.id
       AND c.title = 'fun@Testing$$';

-- delete second document from corpus 'fun@Testing$$'
SELECT lives_ok('DELETE FROM standoff.corpus_document
       			WHERE document = currval(''standoff.document_id_seq'')
			AND corpus = (SELECT id FROM standoff.corpus 
			    	      WHERE title = ''fun@Testing$$'')');

-- frequency of 'the$T' now again equals 2 in corpus 'fun@Testing$$'.
SELECT is(tf.frequency, 2) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'the$T'
       AND tf.corpus = c.id
       AND c.title = 'fun@Testing$$';

-- count of tokens in corpus 'fun@Testing$$' now again equals 10.
SELECT is(c.tokens, 10) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';

-- How many different tokens are there in corpus 'fun@Testing$$'?
SELECT is(count(*)::integer, 9) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.corpus = c.id
       AND c.title = 'fun@Testing$$';

SELECT lives_ok('DELETE FROM standoff.token
       			WHERE token = ''the$T''
			AND document = (SELECT cd.document 
			    	        FROM standoff.corpus_document cd, standoff.corpus c
			    	        WHERE c.title = ''fun@Testing$$''
					AND c.id = cd.corpus)');

-- frequency of 'the$T' now again equals 2 in corpus 'fun@Testing$$'.
SELECT is(tf.frequency, 0) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.token = 'the$T'
       AND tf.corpus = c.id
       AND c.title = 'fun@Testing$$';

-- count of tokens in corpus 'fun@Testing$$' now again equals 10.
SELECT is(c.tokens, 8) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';

-- How many different tokens are there in corpus 'fun@Testing$$'?
SELECT is(count(*)::integer, 8) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.corpus = c.id
       AND c.title = 'fun@Testing$$';

-- deletion of a document should result in cascading deletion of its tokens.
SELECT lives_ok('DELETE FROM standoff.document WHERE id =
       			(SELECT cd.document 
			 FROM standoff.corpus_document cd, standoff.corpus c
			 WHERE c.title = ''fun@Testing$$''
			 AND c.id = cd.corpus)');


-- count of tokens in corpus 'fun@Testing$$' now again equals 10.
SELECT is(c.tokens, 0) FROM standoff.corpus c
       WHERE c.title = 'fun@Testing$$';

-- How many different tokens are there in corpus 'fun@Testing$$'?
SELECT is(count(*)::integer, 0) FROM standoff.token_frequency tf, standoff.corpus c
       WHERE tf.corpus = c.id
       AND c.title = 'fun@Testing$$';

-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
