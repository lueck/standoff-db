-- Start transaction and plan the tests
BEGIN;
SELECT plan(19);
--SELECT * FROM no_plan();

-- Run the tests.

SET ROLE standoffeditor;

SELECT lives_ok('INSERT INTO standoff.ontology (iri, version_info) VALUES
       			(''http://arb.de/ontology/arb/'', ''v0.2'')');


SELECT lives_ok('INSERT INTO standoff.term
       			(ontology, local_name) VALUES
			(currval(''standoff.ontology_id_seq''), ''Beispiel'')');


-- unique combination of namespace and version_info
SELECT throws_ok('INSERT INTO standoff.ontology (iri, version_info) VALUES
       			(''http://arb.de/ontology/arb/'', ''v0.2'')');

-- unique local_name in ontology
SELECT throws_ok('INSERT INTO standoff.term
       			(ontology, local_name) VALUES
			(currval(''standoff.ontology_id_seq''), ''Beispiel'')');


SELECT lives_ok('INSERT INTO standoff.ontology (iri, version_info) VALUES
       			(''http://arb.de/ontology/arb/'', ''v0.3'')');


SELECT lives_ok('INSERT INTO standoff.term
       			(ontology, local_name) VALUES
			(currval(''standoff.ontology_id_seq''), ''Beispiel'')');

SELECT lives_ok('INSERT INTO standoff.term
       			(ontology, local_name) VALUES
			(currval(''standoff.ontology_id_seq''), ''Konzept'')');


SELECT is(version_info, 'v0.3') FROM standoff.ontology o, standoff.term r
       WHERE r.local_name = 'Konzept' AND r.ontology = o.id;


SELECT set_eq('SELECT version_info FROM standoff.ontology o, standoff.term r
       		      WHERE r.local_name = ''Beispiel'' AND r.ontology = o.id',
	      ARRAY['v0.3', 'v0.2']) ;


-- as long as namespace_delimiter is null, there is no qualified name
SELECT is(qualified_name, null)
       FROM standoff.ontology_term
       WHERE local_name = 'Konzept';

-- we set namespace_delimiter to empty string for slash namespaces
SELECT lives_ok('UPDATE standoff.ontology SET namespace_delimiter = ''''
       			WHERE iri = ''http://arb.de/ontology/arb/''');

SELECT is(qualified_name, 'http://arb.de/ontology/arb/Konzept')
       FROM standoff.ontology_term
       WHERE local_name = 'Konzept';


-- for the prefixed name a prefix is required
SELECT is(prefixed_name, null)
       FROM standoff.ontology_term
       WHERE local_name = 'Konzept';

-- we set a prefix.
SELECT lives_ok('UPDATE standoff.ontology SET prefix = ''arb''
       			WHERE iri = ''http://arb.de/ontology/arb/''');


SELECT is(prefix, 'arb')
       FROM standoff.ontology_term
       WHERE local_name = 'Konzept';

SELECT is(prefixed_name, 'arb:Konzept')
       FROM standoff.ontology_term
       WHERE local_name = 'Konzept';


-- standoff.has_term_application is a function that tests if a term
-- has the application column set to a given value.

SELECT isnt(standoff.has_term_application(
       (SELECT currval('standoff.term_id_seq')::int),
       'markup'::varchar),
       true);

SELECT lives_ok('UPDATE standoff.term SET application = ''markup''');

SELECT is(standoff.has_term_application(
       (SELECT currval('standoff.term_id_seq')::int),
       'markup'::varchar),
       true);


-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
