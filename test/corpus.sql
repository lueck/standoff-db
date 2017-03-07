-- Start transaction and plan the tests
BEGIN;
SELECT plan(5);

-- There is already a global in the table. 
SELECT is(count(corpus_type)::integer, 1) FROM standoff.corpus WHERE corpus_type = 'global';

-- There can only be one global corpus.
SELECT throws_ok('INSERT INTO standoff.corpus 
       			 (corpus_type, created_at, created_by, privilege)
			 VALUES (''global'', current_timestamp, current_user, 365)',
		 '23P01',
		 'conflicting key value violates exclusion constraint "corpus_corpus_type_excl"');

-- There can be many user defined collections.
SELECT lives_ok('INSERT INTO standoff.corpus 
       			(corpus_type, title, created_at, created_by, privilege)
			VALUES (''collection'', ''Philosophy'', current_timestamp, current_user, 365)');
SELECT lives_ok('INSERT INTO standoff.corpus 
       			(corpus_type, title, created_at, created_by, privilege)
			VALUES (''collection'', ''Arts'', current_timestamp, current_user, 365)');
SELECT is(count(corpus_type)::integer, 2) FROM standoff.corpus WHERE corpus_type = 'collection';

-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
