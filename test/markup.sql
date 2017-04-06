-- Start transaction and plan the tests
BEGIN;
SELECT plan(19);

-- we drop these triggers because of currval within transaction.
DROP TRIGGER IF EXISTS create_document_corpus ON standoff.document;
DROP TRIGGER IF EXISTS add_document_to_global_corpus ON standoff.document;

SELECT lives_ok('INSERT INTO standoff.mimetype (id) VALUES
       			(''text/plaintext''),
			(''application/failure'')
			ON CONFLICT DO NOTHING');

CREATE ROLE testingbob LOGIN;
CREATE ROLE testingdan LOGIN;
CREATE ROLE testingsid LOGIN;

GRANT standoffuser TO testingbob, testingdan;
GRANT standoffeditor TO testingsid;

RESET ROLE;
SET ROLE testingbob;

-- We first have to create mimetypes, a document, an ontology and terms.

SELECT lives_ok('INSERT INTO standoff.document
		 	(source_base64, mimetype)
		 	VALUES
		 	(encode(''Hallo Welt. Grüße!'', ''base64''), ''text/plaintext'')');


SELECT lives_ok('INSERT INTO standoff.ontology (iri, version_info) VALUES
       			(''http://arb.de/ontology/arb/'', ''v0.2'')');

SELECT lives_ok('INSERT INTO standoff.term
       			(ontology, local_name, application) VALUES
			(currval(''standoff.ontology_id_seq''), ''Beispiel'', ''markup''),
			(currval(''standoff.ontology_id_seq''), ''Marker'', ''markup''),
			(currval(''standoff.ontology_id_seq''), ''reihtAn'', ''relation''),
			(currval(''standoff.ontology_id_seq''), ''Paraphrase'', ''attribute'')');

-- Now we can insert into markup.

-- using the markup term 'Beispiel' is ok.
SELECT lives_ok('INSERT INTO standoff.markup
       			(document, text_range, source_range, id, term) VALUES
			(currval(''standoff.document_id_seq''), ''[23, 42]'', ''[123, 142]'', md5(''testId1'')::uuid, currval(''standoff.term_id_seq'')-2)');

-- using the attribute term 'Paraphrase' voilates the check constraint named "markup_term".
SELECT throws_ok('INSERT INTO standoff.markup
       			 (document, text_range, source_range, id, term) VALUES
			 (currval(''standoff.document_id_seq''), ''[23, 42]'', ''[123, 142]'', md5(''testId2'')::uuid, currval(''standoff.term_id_seq''))',
		 '23514',
		 'new row for relation "markup" violates check constraint "markup_term"');

RESET ROLE;
SET ROLE testingdan;

-- other users can see testingbob's markup with default privileges.
SELECT is(count(*)::integer, 1) FROM standoff.markup m WHERE m.document = currval('standoff.document_id_seq');

SELECT is(t.local_name, 'Marker') FROM standoff.markup m, standoff.term t
       WHERE m.id = md5('testId1')::uuid AND m.term = t.id;

-- but others cannot update it with the default privileges.
SELECT lives_ok('UPDATE standoff.markup SET term = currval(''standoff.term_id_seq'')-3');

SELECT isnt(t.local_name, 'Beispiel') FROM standoff.markup m, standoff.term t
       WHERE m.id = md5('testId1')::uuid AND m.term = t.id;

RESET ROLE;
SET ROLE testingbob;

-- even we setting privilege to ________ ...
SELECT lives_ok('UPDATE standoff.markup SET privilege = 0 WHERE document = currval(''standoff.document_id_seq'')');

-- ... it is effectively set to 448 because rwx is always granted to
-- the owner. This is done be the adjust_privilege_on_update trigger
-- and corresponds to the security policies defined for the relation.
SELECT is(privilege, 448) FROM standoff.markup WHERE document = currval('standoff.document_id_seq');

RESET ROLE;
SET ROLE testingdan;

-- Other users do not see testingbob's markup now.
SELECT is(count(*)::integer, 0) FROM standoff.markup m WHERE m.document = currval('standoff.document_id_seq');

RESET ROLE;
SET ROLE testingbob;

-- Now let's set the privileges more generously:
SELECT lives_ok('UPDATE standoff.markup SET privilege = 511 WHERE document = currval(''standoff.document_id_seq'')');


RESET ROLE;
SET ROLE testingdan;

-- Now other users can see testingbob's markup.
SELECT is(count(*)::integer, 1) FROM standoff.markup m WHERE m.document = currval('standoff.document_id_seq');

-- Now others can even update it.
SELECT lives_ok('UPDATE standoff.markup SET term = currval(''standoff.term_id_seq'')-3');

SELECT is(t.local_name, 'Beispiel') FROM standoff.markup m, standoff.term t
       WHERE m.id = md5('testId1')::uuid AND m.term = t.id;

-- But they cannot take over the markup:
SELECT lives_ok('UPDATE standoff.markup SET created_by = ''testingdan''');

-- The owner is still testingbob. This is asserted by the trigger set_meta_on_update.
SELECT is(created_by, 'testingbob') FROM standoff.markup WHERE id = md5('testId1')::uuid;

-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
