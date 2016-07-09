-- Start transaction and plan the tests
BEGIN;
SELECT plan(13);

SELECT lives_ok('INSERT INTO arb.mimetype (id) VALUES
       			(''text/plaintext''),
			(''application/failure'')');

RESET ROLE;
SET ROLE arbuser;

SELECT lives_ok('INSERT INTO arb.bibliography (id, entry_key, entry_type) VALUES
       			(md5(''doc1'')::uuid, ''KantKdU'', ''book'')');

SELECT lives_ok('INSERT INTO arb.text_document
		 	(id, reference, text, mimetype)
		 	VALUES
		 	(md5(''doc1'')::uuid,
			 md5(''doc1'')::uuid,
			 ''Hallo Welt. Aus Gelsenkürchen.'',
			 ''text/plaintext'')');

SELECT is(source_base64, encode('Hallo Welt. Aus Gelsenkürchen.', 'base64'))
       FROM arb.document WHERE id = md5('doc1')::uuid;

SELECT is(decode(source_base64, 'base64'), 'Hallo Welt. Aus Gelsenkürchen.')
       FROM arb.document WHERE id = md5('doc1')::uuid;

SELECT is(d.id, md5('doc1')::uuid) FROM arb.document d, arb.text_document t
       WHERE decode(d.source_base64, 'base64') = t.text;

SELECT is(source_md5, md5(text)::uuid) FROM arb.text_document
       WHERE id = md5('doc1')::uuid;


-- md5 is unique
SELECT throws_ok('INSERT INTO arb.text_document
		 	(id, reference, text, mimetype)
		 	VALUES
		 	(md5(''docNO'')::uuid,
			 md5(''doc1'')::uuid,
			 ''Hallo Welt. Aus Gelsenkürchen.'',
			 ''text/bitter'')',
		 '23505',
		 'duplicate key value violates unique constraint "document_source_md5_key"');

-- trying to set the checksum is not successful
SELECT throws_ok('INSERT INTO arb.text_document
		 	(id, reference, text, source_md5, mimetype)
		 	VALUES
		 	(md5(''docNO'')::uuid,
			 md5(''doc1'')::uuid,
			 ''Hallo Welt. Aus Gelsenkürchen.'',
			 md5(''fake'')::uuid,
			 ''text/bitter'')',
		 '23505',
		 'duplicate key value violates unique constraint "document_source_md5_key"');


-- documents other than with mimetype text/* are not show in this view:
SELECT lives_ok('INSERT INTO arb.document
		 	(id, reference, source_base64, mimetype)
		 	VALUES
		 	(md5(''doc2'')::uuid,
			 md5(''doc1'')::uuid,
			 ''abcdef12'',
			 ''application/failure'')');

SELECT is(count(id)::integer, 1) FROM arb.text_document WHERE TRUE;


-- md5 sums are correct, everywhere in arb.document
SELECT is(source_md5, md5(decode(source_base64, 'base64'))::uuid) FROM arb.document
       WHERE TRUE;

-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
