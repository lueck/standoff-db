-- Start transaction and plan the tests
BEGIN;
SELECT plan(55);

-- we drop these triggers because of currval within transaction.
DROP TRIGGER IF EXISTS create_document_corpus ON standoff.document;
DROP TRIGGER IF EXISTS add_document_to_global_corpus ON standoff.document;

SELECT lives_ok('INSERT INTO standoff.mimetype (mimetype) VALUES
       			(''text/plaintext''),
			(''application/failure'')
			ON CONFLICT DO NOTHING');

CREATE ROLE testingbob LOGIN;
CREATE ROLE testingdan LOGIN;
CREATE ROLE testingtom LOGIN;
CREATE ROLE testingsid LOGIN;

GRANT standoffuser TO testingbob, testingdan, testingtom;
GRANT standoffeditor TO testingsid;

GRANT testingbob TO testingtom; -- tom is a member of bob's personal group

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
       			(ontology_id, local_name, application) VALUES
			(currval(''standoff.ontology_ontology_id_seq''), ''Beispiel'', ''markup''),
			(currval(''standoff.ontology_ontology_id_seq''), ''Marker'', ''markup''),
			(currval(''standoff.ontology_ontology_id_seq''), ''reihtAn'', ''relation''),
			(currval(''standoff.ontology_ontology_id_seq''), ''Paraphrase'', ''attribute'')');

-- Now we can insert into markup.

-- using the markup term 'Beispiel' is ok.
SELECT lives_ok('INSERT INTO standoff.markup
       			(document_id, markup_id, term_id) VALUES
			(currval(''standoff.document_document_id_seq''), md5(''testId1'')::uuid, currval(''standoff.term_term_id_seq'')-2)');

-- using the attribute term 'Paraphrase' voilates the check constraint named "markup_term".
SELECT throws_ok('INSERT INTO standoff.markup
       			 (document_id, markup_id, term_id) VALUES
			 (currval(''standoff.document_document_id_seq''), md5(''testId2'')::uuid, currval(''standoff.term_term_id_seq''))',
		 '23514',
		 'new row for relation "markup" violates check constraint "markup_term"');

-- We can even insert markup ranges.
SELECT lives_ok('INSERT INTO standoff.markup_range
       			(document_id, markup_id, markup_range_id, text_range, source_range) VALUES
			(currval(''standoff.document_document_id_seq''), md5(''testId1'')::uuid, md5(''testId1.1'')::uuid, ''[23, 42]'', ''[123, 142]''),
			(currval(''standoff.document_document_id_seq''), md5(''testId1'')::uuid, md5(''testId1.2'')::uuid, ''[111, 152]'', ''[211, 252]'')');

-- There are 2 ranges now.
SELECT is(count(*)::integer, 2) FROM standoff.markup_range WHERE markup_id = md5('testId1')::uuid;

-- They can be accessed through the view markup_range_term, too.
SELECT is(count(*)::integer, 2) FROM standoff.markup_range_term WHERE markup_id = md5('testId1')::uuid;


-- We can't add an other range to the related with the same value on text_range.
SELECT throws_ok('INSERT INTO standoff.markup_range
       	  		 (document_id, markup_id, markup_range_id, text_range, source_range) VALUES
			 (currval(''standoff.document_document_id_seq''), md5(''testId1'')::uuid, md5(''testId1.fail'')::uuid, ''[23, 42]'', ''[1000, 9999]'')',
			 '23505',
			 'duplicate key value violates unique constraint "markup_range_markup_id_text_range_key"');

-- Neither with the same value on source_range.
SELECT throws_ok('INSERT INTO standoff.markup_range
       	  		 (document_id, markup_id, markup_range_id, text_range, source_range) VALUES
			 (currval(''standoff.document_document_id_seq''), md5(''testId1'')::uuid, md5(''testId1.fail'')::uuid, ''[1212, 1234]'', ''[123, 142]'')',
			 '23505',
			 'duplicate key value violates unique constraint "markup_range_markup_id_source_range_key"');



-- The group ID (gid) is null by default.
SELECT is(gid, null) FROM standoff.markup WHERE markup_id = md5('testId1')::uuid; 

-- Let's set it to testingbob for later tests.
SELECT lives_ok('UPDATE standoff.markup SET gid = ''testingbob''
       			WHERE markup_id = md5(''testId1'')::uuid');
SELECT is(gid, 'testingbob') FROM standoff.markup WHERE markup_id = md5('testId1')::uuid;


RESET ROLE;
SET ROLE testingdan;

-- other users can see testingbob's markup with default privileges.
SELECT is(count(*)::integer, 1) FROM standoff.markup
       WHERE document_id = currval('standoff.document_document_id_seq');

SELECT is(t.local_name, 'Marker') FROM standoff.markup m, standoff.term t
       WHERE m.markup_id = md5('testId1')::uuid AND m.term_id = t.term_id;

-- other users can also see the markup ranges with default privileges on markup.
SELECT is(count(*)::integer, 2) FROM standoff.markup_range
       WHERE markup_id = md5('testId1')::uuid;

-- Same with the view.
SELECT is(count(*)::integer, 2) FROM standoff.markup_range_term
       WHERE markup_id = md5('testId1')::uuid;

-- other users can even add markup ranges with default privileges on markup.
SELECT lives_ok('INSERT INTO standoff.markup_range
       			(document_id, markup_id, markup_range_id, text_range, source_range) VALUES
			(currval(''standoff.document_document_id_seq''), md5(''testId1'')::uuid, md5(''testId1.3'')::uuid, ''[186, 192]'', ''[286, 292]'')');

SELECT is(count(*)::integer, 3) FROM standoff.markup_range
       WHERE markup_id = md5('testId1')::uuid;

-- but others cannot update it with the default privileges.
SELECT lives_ok('UPDATE standoff.markup SET term_id = currval(''standoff.term_term_id_seq'')-3');

SELECT isnt(t.local_name, 'Beispiel') FROM standoff.markup m, standoff.term t
       WHERE m.markup_id = md5('testId1')::uuid AND m.term_id = t.term_id;

-- Now let's change the privileges:

RESET ROLE;
SET ROLE testingbob;

-- even we setting privilege to ________ ...
SELECT lives_ok('UPDATE standoff.markup SET privilege = 0
       WHERE document_id = currval(''standoff.document_document_id_seq'')');

-- ... it is effectively set to 448 because rwx is always granted to
-- the owner. This is done be the adjust_privilege_on_update trigger
-- and corresponds to the security policies defined for the relation.
SELECT is(privilege, 448) FROM standoff.markup
       WHERE document_id = currval('standoff.document_document_id_seq');

-- the owner of the markup row can still see all related markup ranges
SELECT is(count(*)::integer, 3) FROM standoff.markup_range
       WHERE markup_id = md5('testId1')::uuid;

-- Same with the view.
SELECT is(count(*)::integer, 3) FROM standoff.markup_range_term
       WHERE markup_id = md5('testId1')::uuid;

-- the following is used below. Here we only assert that it works.
SELECT is(count(t.local_name)::integer, 1)
       FROM standoff.markup_range r, standoff.markup m, standoff.term t
       WHERE r.markup_range_id = md5('testId1.3')::uuid
       AND r.markup_id = m.markup_id
       AND t.term_id = m.term_id; 


RESET ROLE;
SET ROLE testingdan;

-- Other users do not see testingbob's markup now.
SELECT is(count(*)::integer, 0) FROM standoff.markup m
       WHERE m.document_id = currval('standoff.document_document_id_seq');

-- Other users cannot see the markup ranges, only the ones created by
-- oneself. So testingdan can see one. He cannot see its term. That's
-- ugly, but it complies the policy that objects created by oneself
-- are always selectable.
SELECT is(count(*)::integer, 1) FROM standoff.markup_range
       WHERE markup_id = md5('testId1')::uuid;

-- Same on the markup_range_term view.
SELECT is(count(*)::integer, 1) FROM standoff.markup_range_term
       WHERE markup_id = md5('testId1')::uuid;

-- He really can see no term.
SELECT is(count(t.local_name)::integer, 0)
       FROM standoff.markup_range r, standoff.markup m, standoff.term t
       WHERE r.markup_range_id = md5('testId1.3')::uuid
       AND r.markup_id = m.markup_id
       AND t.term_id = m.term_id; 

-- Due to the fact that a view is called with the permissions of its
-- creator, the term is accessible through the markup_range_term: Do
-- we want that?
SELECT todo(1, 'FIXME: But the term is still present through the view.');
SELECT isnt(local_name, 'Marker') FROM standoff.markup_range_term
       WHERE markup_range_id = md5('testId1.3')::uuid;

RESET ROLE;
SET ROLE testingtom;

-- Even group members can neither see bob's markup ...
SELECT is(count(*)::integer, 0) FROM standoff.markup m
       WHERE m.document_id = currval('standoff.document_document_id_seq');

-- ... nor his ranges ...
SELECT is(count(*)::integer, 0) FROM standoff.markup_range
       WHERE markup_id = md5('testId1')::uuid;

-- ... nor rows on the markup_range_term view.
SELECT is(count(*)::integer, 0) FROM standoff.markup_range_term
       WHERE markup_id = md5('testId1')::uuid;



RESET ROLE;
SET ROLE testingbob;

-- Now let's set the privileges more generously: rw_____rw_
SELECT lives_ok('UPDATE standoff.markup SET privilege = 390 
       WHERE document_id = currval(''standoff.document_document_id_seq'')');


RESET ROLE;
SET ROLE testingdan;

-- Now other users can see testingbob's markup ...
SELECT is(count(*)::integer, 1) FROM standoff.markup m
       WHERE m.document_id = currval('standoff.document_document_id_seq');

-- ... and the ranges.
SELECT is(count(*)::integer, 3) FROM standoff.markup_range
       WHERE markup_id = md5('testId1')::uuid;

-- Same on the markup_range_term view.
SELECT is(count(*)::integer, 3) FROM standoff.markup_range_term
       WHERE markup_id = md5('testId1')::uuid;

-- Now others can even update it.
SELECT lives_ok('UPDATE standoff.markup SET term_id = currval(''standoff.term_term_id_seq'')-3');

SELECT is(t.local_name, 'Beispiel') FROM standoff.markup m, standoff.term t
       WHERE m.markup_id = md5('testId1')::uuid AND m.term_id = t.term_id;

-- But they cannot take over the markup:
SELECT lives_ok('UPDATE standoff.markup SET created_by = ''testingdan''');

-- The owner is still testingbob. This is asserted by the trigger set_meta_on_update.
SELECT is(created_by, 'testingbob') FROM standoff.markup
       WHERE markup_id = md5('testId1')::uuid;

-- Adding markup ranges requires x set. testingdan can't add ranges now.

SELECT throws_ok('INSERT INTO standoff.markup_range
       		 	 (document_id, markup_id, markup_range_id, text_range, source_range) VALUES
			 (currval(''standoff.document_document_id_seq''), md5(''testId1'')::uuid, md5(''testId1.4'')::uuid, ''[086, 099]'', ''[186, 199]'')',
		 '42501',
		 'new row violates row-level security policy for table "markup_range"');


RESET ROLE;
SET ROLE testingbob;

-- Now let's set the privileges more generously to group members: rw_rw____
SELECT lives_ok('UPDATE standoff.markup SET privilege = 432
       WHERE document_id = currval(''standoff.document_document_id_seq'')');

-- Now let's see what a group member can do.
RESET ROLE;
SET ROLE testingtom;

-- Now group members can see testingbob's markup ...
SELECT is(count(*)::integer, 1) FROM standoff.markup m
       WHERE m.document_id = currval('standoff.document_document_id_seq');

-- ... and his ranges, too.
SELECT is(count(*)::integer, 3) FROM standoff.markup_range
       WHERE markup_id = md5('testId1')::uuid;

-- Same on the view markup_range_term.
SELECT is(count(*)::integer, 3) FROM standoff.markup_range_term
       WHERE markup_id = md5('testId1')::uuid;

-- Now others can even update it.
SELECT lives_ok('UPDATE standoff.markup SET term_id = currval(''standoff.term_term_id_seq'')-3');

SELECT is(t.local_name, 'Beispiel') FROM standoff.markup m, standoff.term t
       WHERE m.markup_id = md5('testId1')::uuid AND m.term_id = t.term_id;

-- But they cannot take over the markup:
SELECT lives_ok('UPDATE standoff.markup SET created_by = ''testingtom''');

-- The owner is still testingbob. This is asserted by the trigger
-- set_meta_on_update.
SELECT is(created_by, 'testingbob') FROM standoff.markup
       WHERE markup_id = md5('testId1')::uuid;

-- Adding markup ranges requires x set. testingdan can't add ranges now.

SELECT throws_ok('INSERT INTO standoff.markup_range
       		 	 (document_id, markup_id, markup_range_id, text_range, source_range) VALUES
			 (currval(''standoff.document_document_id_seq''), md5(''testId1'')::uuid, md5(''testId1.4'')::uuid, ''[086, 099]'', ''[186, 199]'')',
		 '42501',
		 'new row violates row-level security policy for table "markup_range"');

-- So let's add this x permission:

RESET ROLE;
SET ROLE testingbob;

SELECT lives_ok('UPDATE standoff.markup SET privilege = 391 
       WHERE document_id = currval(''standoff.document_document_id_seq'')');


RESET ROLE;
SET ROLE testingtom;

-- Now the group member can insert ranges.
SELECT lives_ok('INSERT INTO standoff.markup_range
       		 	(document_id, markup_id, markup_range_id, text_range, source_range) VALUES
			(currval(''standoff.document_document_id_seq''), md5(''testId1'')::uuid, md5(''testId1.4'')::uuid, ''[086, 099]'', ''[186, 199]'')');


-- The markup_range_term view:

-- The view is only accessable by editors. Allowing access by public
-- or standoffeditor would break security policies.

-- SELECT table_privs_are('standoff', 'markup_range_term', 'public', ARRAY[]::varchar[]);
-- SELECT table_privs_are('standoff', 'markup_range_term', 'standoffuser', ARRAY[]::varchar[]);
-- SELECT table_privs_are('standoff', 'markup_range_term', 'standoffeditor', ARRAY['SELECT']);



-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
