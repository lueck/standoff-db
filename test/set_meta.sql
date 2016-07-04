-- Start transaction and plan the tests
BEGIN;
SELECT plan(9);

SET search_path TO arb, public;

-- Setup.
CREATE TABLE IF NOT EXISTS meta_data (
	a_number integer not null,
	-- these cols may be copied:
	created_at timestamp not null DEFAULT current_timestamp,
	created_by varchar not null,
	updated_at timestamp null,
	updated_by varchar null,
	gid varchar null,
	privilege integer not null DEFAULT 492
	--
	);

CREATE TRIGGER meta_data_set_meta_on_insert BEFORE INSERT ON meta_data
    FOR EACH ROW EXECUTE PROCEDURE arb.set_meta_on_insert();

SELECT todo(1);
SELECT lives_ok('
CREATE TRIGGER meta_data_set_meta_on_upate BEFORE UPDATE ON meta_data
    FOR EACH ROW EXECUTE PROCEDURE arb.set_meta_on_update()');

-- Run the tests.
INSERT INTO meta_data (a_number) VALUES (1);
SELECT is(created_by, current_user::varchar) FROM meta_data WHERE a_number = 1;
-- SELECT is(gid, current_user) FROM meta_data WHERE a_number = 1;
SELECT isnt(created_at, null) FROM meta_data WHERE a_number = 1;
SELECT is(updated_by, null) FROM meta_data WHERE a_number = 1;
SELECT is(updated_at, null) FROM meta_data WHERE a_number = 1;

SELECT lives_ok('UPDATE meta_data SET (created_by) = (''someone else'') WHERE a_number=1');
SELECT todo(3);
SELECT isnt(updated_by, null) FROM meta_data WHERE a_number = 1;
SELECT isnt(updated_at, null) FROM meta_data WHERE a_number = 1;
SELECT is(created_by, current_user::varchar) FROM meta_data WHERE a_number = 1;


-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
