-- Start transaction and plan the tests
BEGIN;
SELECT plan(10);

-- There is already a global corpus in the table.
SELECT is(count(corpus_type)::integer, 1) FROM standoff.corpus WHERE corpus_type = 'global';

-- There can only be one global corpus.
SELECT throws_ok('INSERT INTO standoff.corpus 
       			 (corpus_type, created_at, created_by, privilege)
			 VALUES (''global'', current_timestamp, current_user, 365)',
		 '23P01',
		 'conflicting key value violates exclusion constraint "corpus_corpus_type_excl"');

CREATE ROLE testingbob LOGIN;
GRANT standoffuser TO testingbob;

RESET ROLE;
SET ROLE testingbob;

-- When we do this as a non super user the RLS policies prevent from
-- adding a corpus_type <> 'collection'.
SELECT throws_ok('INSERT INTO standoff.corpus 
       			 (corpus_type, created_at, created_by, privilege)
			 VALUES (''global'', current_timestamp, current_user, 365)',
		 '42501',
		 'new row violates row-level security policy for table "corpus"');

-- There can be many user defined collections.
SELECT lives_ok('INSERT INTO standoff.corpus 
       			(corpus_type, title, created_at, created_by, privilege)
			VALUES (''collection'', ''Philosophy'', current_timestamp, current_user, 365)');
SELECT lives_ok('INSERT INTO standoff.corpus
       			(corpus_type, title, created_at, created_by, privilege)
			VALUES (''collection'', ''Arts'', current_timestamp, current_user, 365)');

SELECT is(count(corpus_type)::integer, 2) FROM standoff.corpus WHERE created_by = 'testingbob';

-- It is not allowed to update the columns 'tokens' or
-- 'tokens_dedupl'. They are calculated automatically by triggers on
-- insertions of tokens.

SELECT throws_ok('UPDATE standoff.corpus SET tokens = 23
       			 WHERE created_by = ''testingbob''',
		 '42501',
		 'permission denied for relation corpus');

SELECT throws_ok('UPDATE standoff.corpus SET tokens_dedupl = 23
       			 WHERE created_by = ''testingbob''',
		 '42501',
		 'permission denied for relation corpus');

-- Likewise it is not allowed to set these columns on insert.

SELECT throws_ok('INSERT INTO standoff.corpus
       			(corpus_type, title, tokens, created_at, created_by, privilege)
			VALUES (''collection'', ''Medical science'', 23, current_timestamp, current_user, 365)',
		 '42501',
		 'permission denied for relation corpus');

SELECT throws_ok('INSERT INTO standoff.corpus
       			(corpus_type, title, tokens_dedupl, created_at, created_by, privilege)
			VALUES (''collection'', ''Medical science'', 23, current_timestamp, current_user, 365)',
		 '42501',
		 'permission denied for relation corpus');


-- FIXME: Add more tests for RLS 

-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
