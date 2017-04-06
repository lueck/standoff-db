-- Start transaction and plan the tests
BEGIN;
SELECT * FROM no_plan();

-- Run the tests.

SET ROLE standoffeditor;

SELECT lives_ok('INSERT INTO standoff.ontology (namespace, version) VALUES
       			(''http://arb.de/ontology/arb/'', ''v0.2'')');


SELECT lives_ok('INSERT INTO standoff.term
       			(ontology, local_name) VALUES
			(currval(''standoff.ontology_id_seq''), ''Beispiel'')');


-- unique combination of namespace and version
SELECT throws_ok('INSERT INTO standoff.ontology (namespace, version) VALUES
       			(''http://arb.de/ontology/arb/'', ''v0.2'')');

-- unique local_name in ontology
SELECT throws_ok('INSERT INTO standoff.term
       			(ontology, local_name) VALUES
			(currval(''standoff.ontology_id_seq''), ''Beispiel'')');


SELECT lives_ok('INSERT INTO standoff.ontology (namespace, version) VALUES
       			(''http://arb.de/ontology/arb/'', ''v0.3'')');


SELECT lives_ok('INSERT INTO standoff.term
       			(ontology, local_name) VALUES
			(currval(''standoff.ontology_id_seq''), ''Beispiel'')');

SELECT lives_ok('INSERT INTO standoff.term
       			(ontology, local_name) VALUES
			(currval(''standoff.ontology_id_seq''), ''Konzept'')');


SELECT is(version, 'v0.3') FROM standoff.ontology o, standoff.term r
       WHERE r.local_name = 'Konzept' AND r.ontology = o.id;


SELECT set_eq('SELECT version FROM standoff.ontology o, standoff.term r
       		      WHERE r.local_name = ''Beispiel'' AND r.ontology = o.id',
	      ARRAY['v0.3', 'v0.2']) ;


SELECT is(qualified_name, 'http://arb.de/ontology/arb/Konzept')
       FROM standoff.ontology_term
       WHERE local_name = 'Konzept';

SELECT is(prefix, null)
       FROM standoff.ontology_term
       WHERE local_name = 'Konzept';


-- we can set a system-wide preferred prefix.
SELECT lives_ok('INSERT INTO standoff.system_prefix (namespace, prefix) VALUES
       			(''http://arb.de/ontology/arb/'', ''arb'')');


SELECT is(prefix, 'arb')
       FROM standoff.ontology_term
       WHERE local_name = 'Konzept';

SELECT is(prefixed_name, 'arb:Konzept')
       FROM standoff.ontology_term
       WHERE local_name = 'Konzept';

-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
