-- Start transaction and plan the test.
BEGIN;
SELECT plan(57);

SET search_path TO arb, public;

SELECT has_table('bibliography');
SELECT has_pk('bibliography');

SELECT has_column('bibliography', 'id');
SELECT col_type_is('bibliography', 'id', 'uuid');
SELECT col_has_default('bibliography', 'id');
SELECT col_is_pk('bibliography', 'id');

SELECT has_column('bibliography', 'entry_key');
SELECT col_type_is('bibliography', 'entry_key', 'character varying(1023)');
SELECT col_hasnt_default('bibliography', 'entry_key');
SELECT col_not_null('bibliography', 'entry_key');
SELECT col_is_unique('bibliography', 'entry_key');

SELECT has_column('bibliography', 'entry_type');
SELECT col_type_is('bibliography', 'entry_type', 'character varying(20)');
SELECT col_hasnt_default('bibliography', 'entry_type');
SELECT col_not_null('bibliography', 'entry_type');

SELECT has_column('bibliography', 'created_at');
SELECT has_column('bibliography', 'created_by');
SELECT has_column('bibliography', 'updated_at');
SELECT has_column('bibliography', 'updated_by');
SELECT has_column('bibliography', 'gid');
SELECT has_column('bibliography', 'privilege');


-- create some login roles for testing row level security:
CREATE ROLE testingbob LOGIN;
CREATE ROLE testingdan LOGIN;
CREATE ROLE testingalf LOGIN;
CREATE ROLE testingsid LOGIN;

GRANT arbuser TO testingbob, testingdan, testingalf, testingsid;

CREATE ROLE biblio_working_group ROLE testingbob, testingdan;

GRANT arbeditor TO testingsid;

SET ROLE testingdan;
SELECT is(current_user, 'testingdan');


SELECT lives_ok('INSERT INTO arb.bibliography (entry_key, entry_type)
       			VALUES (''Kant1790a'', ''article'')');

-- meta data set by trigger
SELECT is(created_by, current_user::varchar) FROM bibliography WHERE entry_key = 'Kant1790a';
SELECT isnt(created_at, null) FROM bibliography WHERE entry_key = 'Kant1790a';
SELECT is(updated_by, null) FROM bibliography WHERE entry_key = 'Kant1790a';
SELECT is(updated_at, null) FROM bibliography WHERE entry_key = 'Kant1790a';

-- entry_key is unique:
SELECT throws_ok('INSERT INTO arb.bibliography (entry_key, entry_type)
       			VALUES (''Kant1790a'', ''article'')',
		 '23505',
		 'duplicate key value violates unique constraint "bibliography_entry_key_key"');


RESET ROLE;
SET ROLE testingbob;
SELECT is(current_user, 'testingbob');

-- others are allowed to select
SELECT is(entry_type, 'article') FROM arb.bibliography WHERE entry_key = 'Kant1790a';

-- but can't update
SELECT lives_ok('UPDATE arb.bibliography SET (entry_type) = (''book'')
       			WHERE entry_key = ''Kant1790a''');
SELECT is(entry_type, 'article') FROM arb.bibliography WHERE entry_key = 'Kant1790a';

-- and can't delete rows created by others
SELECT lives_ok('DELETE FROM arb.bibliography WHERE entry_key = ''Kant1790a''');
SELECT is(entry_type, 'article') FROM arb.bibliography WHERE entry_key = 'Kant1790a';


-- one can update one's own rows.
SELECT lives_ok('INSERT INTO bibliography (entry_key, entry_type, gid, privilege) VALUES
       			(''Kant1781a'', ''book'', ''biblio_working_group'', 511),
       			(''Kant1783a'', ''book'', ''biblio_working_group'', 509),
       			(''Kant1787a'', ''book'', ''biblio_working_group'', 509),
			(''Kant1788a'', ''book'', ''biblio_working_group'', 509)');
SELECT lives_ok('UPDATE bibliography SET (entry_type) = (''article'')
       			WHERE entry_key = ''Kant1787a''');
SELECT is(entry_type, 'article') FROM arb.bibliography WHERE entry_key = 'Kant1787a';
SELECT is(updated_by, current_user::varchar) FROM arb.bibliography WHERE entry_key = 'Kant1787a';
SELECT isnt(updated_at, null) FROM arb.bibliography WHERE entry_key = 'Kant1787a';

-- and on can delete one's own rows.

SELECT lives_ok('DELETE FROM arb.bibliography WHERE entry_key = ''Kant1783a''');
SELECT is(entry_type, null) FROM arb.bibliography WHERE entry_key = 'Kant1783a';


-- group members can update

RESET ROLE;
SET ROLE testingdan;

SELECT isnt(entry_type, 'book') FROM arb.bibliography WHERE entry_key = 'Kant1787a';
SELECT lives_ok('UPDATE bibliography SET (entry_type) = (''book'')
       			WHERE entry_key = ''Kant1787a''');
SELECT is(entry_type, 'book') FROM arb.bibliography WHERE entry_key = 'Kant1787a';

SELECT is(updated_by, current_user::varchar) FROM arb.bibliography WHERE entry_key = 'Kant1787a';
SELECT isnt(updated_at, null) FROM arb.bibliography WHERE entry_key = 'Kant1787a';

-- group members can't delete

SELECT lives_ok('DELETE FROM arb.bibliography WHERE entry_key = ''Kant1788a''');
SELECT is(entry_type, 'book') FROM arb.bibliography WHERE entry_key = 'Kant1788a';


-- others can update entry_key = 'Kant1781a', because privilege & 2 = 2, i.e. others = *w*

RESET ROLE;
SET ROLE testingalf;

SELECT lives_ok('UPDATE bibliography SET (entry_type) = (''article'')
       			WHERE entry_key = ''Kant1781a''');
SELECT is(entry_type, 'article') FROM arb.bibliography WHERE entry_key = 'Kant1781a';


-- arbeditors are allowed to update:

RESET ROLE;
SET ROLE testingsid;

SELECT isnt(entry_type, 'article') FROM arb.bibliography WHERE entry_key = 'Kant1787a';
SELECT lives_ok('UPDATE bibliography SET (entry_type) = (''article'')
       			WHERE entry_key = ''Kant1787a''');
SELECT is(entry_type, 'article') FROM arb.bibliography WHERE entry_key = 'Kant1787a';


-- one can't set created_by to someone else

RESET ROLE;
SET ROLE testingalf;

SELECT throws_ok('INSERT INTO arb.bibliography (entry_key, entry_type, created_by) VALUES
       			 (''PLogin1763'', ''book'', ''testingsid'')',
		'42501',
		'new row violates row-level security policy for table "bibliography"');


-- but arbeditors are allowed to insert in the name of other users.

RESET ROLE;
SET ROLE testingsid;

SELECT lives_ok('INSERT INTO arb.bibliography (entry_key, entry_type, created_by) VALUES
       			 (''PLogin1763'', ''book'', ''testingbob'')');
SELECT is(created_by, 'testingbob') FROM arb.bibliography WHERE entry_key = 'PLogin1763';

-- arbeditor is allowed to delete

SELECT lives_ok('DELETE FROM arb.bibliography WHERE entry_key = ''PLogin1763''');
SELECT is(entry_type, null) FROM arb.bibliography WHERE entry_key = 'PLogin1763';

SELECT lives_ok('DELETE FROM arb.bibliography WHERE entry_key = ''Kant1781a''');
SELECT is(entry_type, null) FROM arb.bibliography WHERE entry_key = 'Kant1781a';


-- Clean up.
SELECT finish();
ROLLBACK;
