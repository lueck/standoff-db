-- Start transaction and plan the tests
BEGIN;
--SELECT plan(1);
SELECT * FROM no_plan();

SELECT lives_ok('INSERT INTO standoff.mimetype (id) VALUES
       			(''text/plaintext''),
			(''application/failure'')');

SELECT lives_ok('INSERT INTO standoff.bibliography (id, entry_key, entry_type) VALUES
       			(md5(''bib1'')::uuid, ''bib1'', ''book'')');

CREATE ROLE testingbob LOGIN;
CREATE ROLE testingdan LOGIN;
CREATE ROLE testingsid LOGIN;

GRANT standoffuser TO testingbob, testingdan;
GRANT standoffeditor TO testingsid;

RESET ROLE;
SET ROLE testingbob;

SELECT lives_ok('INSERT INTO standoff.document
		 	(id, reference, source_base64, mimetype)
		 	VALUES
		 	(md5(''doc1'')::uuid,
			 md5(''bib1'')::uuid,
			 encode(''Hallo Welt. Grüße!'', ''base64''),
			 ''text/plaintext'')');

-- the md5 hash of the content, i.e. decode(source_base64, 'base64')
-- is unique.
SELECT throws_ok('INSERT INTO standoff.document
		 	 (id, reference, source_base64, mimetype)
		 	 VALUES
		 	 (md5(''doc2'')::uuid,
			  md5(''bib1'')::uuid,
			  encode(''Hallo Welt. Grüße!'', ''base64''),
			  ''text/plaintext'')',
			  '23505',
			  'duplicate key value violates unique constraint "document_source_md5_key"');

-- trying to insert non-base64 encoded value:
SELECT throws_ok('INSERT INTO standoff.document
		 	 (id, reference, source_base64, mimetype)
		 	 VALUES
		 	 (md5(''doc2'')::uuid,
			  md5(''bib1'')::uuid,
			  ''BAD VALUE!'',
			  ''text/plaintext'')',
			  '22023',
			  'invalid symbol "!" while decoding base64 sequence');

-- we can't update source_base64
SELECT throws_ok('UPDATE standoff.document SET (source_base64) = (encode(''Changed!'', ''base64''))
       				     WHERE id = md5(''doc1'')::uuid',
		 '42501',
		 'permission denied for relation document');

-- standoffusers can't update
SELECT throws_ok('UPDATE standoff.document SET (source_charset) = (''utf-8'')
       				     WHERE id = md5(''doc1'')::uuid',
		 '42501',
		 'permission denied for relation document');

RESET ROLE;
SET ROLE testingsid;

-- standoffeditors (and standoffadmins) can update
SELECT lives_ok('UPDATE standoff.document SET (source_charset) = (''utf-8'')
       				     WHERE id = md5(''doc1'')::uuid');


-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
