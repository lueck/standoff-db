-- Start transaction and plan the tests
BEGIN;
SELECT plan(16);

-- we drop these triggers because of currval within transaction.
DROP TRIGGER IF EXISTS create_document_corpus ON standoff.document;
DROP TRIGGER IF EXISTS add_document_to_global_corpus ON standoff.document;

SELECT lives_ok('INSERT INTO standoff.mimetype (id) VALUES
       			(''text/plaintext''),
			(''application/failure'')
			ON CONFLICT DO NOTHING');

RESET ROLE;
SET ROLE standoffuser;

SELECT lives_ok('INSERT INTO standoff.bibliography (id, entry_key, entry_type) VALUES
       			(md5(''doc1'')::uuid, ''KantKdU'', ''book'')');

SELECT lives_ok('INSERT INTO standoff.text_document
		 	(reference, text, mimetype)
		 	VALUES
		 	(md5(''doc1'')::uuid,
			 ''Hallo Welt. Grüße!'',
			 ''text/plaintext'')');

SELECT is(source_base64, encode('Hallo Welt. Grüße!', 'base64'))
       FROM standoff.document WHERE id = currval('standoff.document_id_seq');

SELECT is(decode(source_base64, 'base64'), 'Hallo Welt. Grüße!')
       FROM standoff.document WHERE id = currval('standoff.document_id_seq');

SELECT is(d.id, currval('standoff.document_id_seq')::integer) FROM standoff.document d, standoff.text_document t
       WHERE convert_from(decode(d.source_base64, 'base64'), 'utf-8') = t.text AND t.text = 'Hallo Welt. Grüße!';

SELECT is(source_md5, md5(text)::uuid) FROM standoff.text_document
       WHERE id = currval('standoff.document_id_seq');


-- md5 is unique
SELECT throws_ok('INSERT INTO standoff.text_document
		 	(reference, text, mimetype)
		 	VALUES
		 	(md5(''doc1'')::uuid,
			 ''Hallo Welt. Grüße!'',
			 ''text/bitter'')',
		 '23505',
		 'duplicate key value violates unique constraint "document_source_md5_key"');

-- trying to set the checksum is not successful
SELECT throws_ok('INSERT INTO standoff.text_document
		 	(reference, text, source_md5, mimetype)
		 	VALUES
		 	(md5(''doc1'')::uuid,
			 ''Hallo Welt. Grüße!'',
			 md5(''fake'')::uuid,
			 ''text/bitter'')',
		 '23505',
		 'duplicate key value violates unique constraint "document_source_md5_key"');


-- documents other than with mimetype text/* are not shown in this view:
SELECT lives_ok('INSERT INTO standoff.document
		 	(reference, source_base64, mimetype)
		 	VALUES
		 	(md5(''doc1'')::uuid,
			 ''abcdef12'',
			 ''application/failure'')');

SELECT is(count(id)::integer, 0) FROM standoff.text_document WHERE id = currval('standoff.document_id_seq');


-- md5 sums are correct, everywhere in standoff.document
SELECT is(source_md5, md5(decode(source_base64, 'base64'))::uuid) FROM standoff.document
       WHERE id = currval('standoff.document_id_seq');

-- we can't update column text
SELECT throws_ok('UPDATE standoff.text_document SET (text) = (''Hello world!'')
       					  WHERE id = currval(''standoff.document_id_seq'')',
		 '0A000',
		 'cannot update column "text" of view "text_document"');

-- but we can update other columns
SELECT lives_ok('UPDATE standoff.text_document SET (source_charset) = (''UTF8'')
       					  WHERE id = currval(''standoff.document_id_seq'')');

-- setting source_md5 to an arbitrary value is not successful
SELECT lives_ok('UPDATE standoff.text_document SET (source_md5) = (md5(''UTF8'')::uuid)
       					  WHERE id = currval(''standoff.document_id_seq'')');

SELECT is(source_md5, md5('Hallo Welt. Grüße!')::uuid) FROM standoff.text_document
       WHERE text = 'Hallo Welt. Grüße!';


-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
