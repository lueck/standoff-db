-- Start transaction and plan the tests
BEGIN;
SELECT plan(13);

-- First add mimetypes
SELECT lives_ok('INSERT INTO standoff.mimetype (id) VALUES
       			(''text/plaintext''),
			(''text/xml''),
			(''application/failure'')
			ON CONFLICT DO NOTHING');

-- And we need a reference before.
SELECT lives_ok('INSERT INTO standoff.bibliography (id, entry_key, entry_type) VALUES
       			(md5(''doc1'')::uuid, ''KantKdU'', ''book'')');


RESET ROLE;
SET ROLE standoffuser;

-- create document 1
SELECT lives_ok('INSERT INTO standoff.document
		 	(reference, source_base64, mimetype)
		 	VALUES
		 	(md5(''doc1'')::uuid,
			 encode(''Hallo Welt. Grüße!'', ''base64''),
			 ''text/plaintext'')');

SELECT is(count(*)::integer, 2) FROM standoff.corpus_document
       WHERE document = currval('standoff.document_id_seq');

-- the privilege of the document corpus is 444. So one can't update or
-- insert documents.
SELECT is(c.privilege, 292) FROM standoff.corpus c, standoff.corpus_document cd
       WHERE cd.corpus = c.id
       AND cd.document = currval('standoff.document_id_seq')
       AND c.corpus_type = 'document'::standoff.corpus_types;

-- The creator of the corpus is the definer of the trigger.
SELECT isnt(c.created_by, 'standoffuser'::varchar) FROM standoff.corpus c, standoff.corpus_document cd
       WHERE cd.corpus = c.id
       AND cd.document = currval('standoff.document_id_seq')
       AND c.corpus_type = 'document'::standoff.corpus_types;

SET ROLE standoffuser;

SELECT is(count(*)::integer, 1) FROM standoff.corpus_document cd, standoff.corpus c
       WHERE cd.document = currval('standoff.document_id_seq')
       AND cd.corpus = c.id
       AND c.corpus_type = 'global';

SELECT is(count(*)::integer, 1) FROM standoff.corpus_document cd, standoff.corpus c
       WHERE cd.document = currval('standoff.document_id_seq')
       AND cd.corpus = c.id
       AND c.corpus_type = 'document';

-- create document 2
SELECT lives_ok('INSERT INTO standoff.document
		 	(reference, source_base64, mimetype)
		 	VALUES
		 	(md5(''doc1'')::uuid,
			 encode(''Hallo Welt. Noch mehr Grüße!'', ''base64''),
			 ''text/plaintext'')');

-- We can't add a document to a document corpus.

-- Try to add document 1 corpus for second document 
SELECT throws_ok('INSERT INTO standoff.corpus_document
       			(corpus, document) VALUES
			(currval(''standoff.corpus_id_seq''),
			 (SELECT id FROM standoff.document WHERE source_base64 = encode(''Hallo Welt. Grüße!'', ''base64'')))',
	         'P0001',
		 'A corpus of type ''document'' may only contain one document'); 

SELECT is(count(*)::integer, 1)
       FROM standoff.corpus_document cd, standoff.corpus c, standoff.document d
       WHERE d.source_base64 = encode('Hallo Welt. Grüße!', 'base64')
       AND d.id = cd.document
       AND cd.corpus = c.id
       AND c.corpus_type = 'document';

-- Deletion of document deletes it from corpuses.

SELECT lives_ok('DELETE FROM standoff.document WHERE id = currval(''standoff.document_id_seq'')');

SELECT is(count(*)::integer, 0) FROM standoff.corpus_document
       WHERE document = currval('standoff.document_id_seq');

-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
