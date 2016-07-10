-- Start transaction and plan the tests
BEGIN;
SELECT plan(29);

SET search_path TO arb, public;

-- Setup.
CREATE TABLE IF NOT EXISTS meta_data (
	a_number integer not null,
	val integer,
	-- these cols may be copied:
	privilege integer not null DEFAULT 492
	--
	);

CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON meta_data
    FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(484);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON meta_data
    FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(484);

-- Run the tests.
INSERT INTO meta_data (a_number, privilege) VALUES (1, 320);
SELECT is(privilege & 1, 0) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 2, 0) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 4, 4) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 8, 0) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 16, 0) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 32, 32) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 64, 64) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 128, 128) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 256, 256) FROM meta_data WHERE a_number = 1;


SELECT lives_ok('UPDATE meta_data SET (privilege) = (7) WHERE a_number=1');
SELECT is(privilege & 1, 1) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 2, 2) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 4, 4) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 8, 0) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 16, 0) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 32, 32) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 64, 64) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 128, 128) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 256, 256) FROM meta_data WHERE a_number = 1;

SELECT lives_ok('UPDATE meta_data SET (val) = (2016) WHERE a_number=1');
SELECT is(privilege & 1, 1) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 2, 2) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 4, 4) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 8, 0) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 16, 0) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 32, 32) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 64, 64) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 128, 128) FROM meta_data WHERE a_number = 1;
SELECT is(privilege & 256, 256) FROM meta_data WHERE a_number = 1;



-- Finish the tests and clean up.
SELECT finish();
ROLLBACK;
