-- Deploy arb-db:bibliography_field to pg
-- requires: arbschema
-- requires: arbroles
-- requires: bibliography
-- requires: field_type

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.bibliography_field (
       bibliography_id uuid not null REFERENCES standoff.bibliography,
       field_type varchar(20) not null REFERENCES standoff.field_type,
       val text not null,
       created_at timestamp not null,
       created_by varchar not null,
       updated_at timestamp,
       updated_by varchar,
       gid varchar,
       privilege integer not null DEFAULT 509,
       UNIQUE (bibliography_id, field_type));

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE standoff.bibliography_field
TO standoffadmin, standoffeditor, standoffuser;


-- CREATE OR REPLACE FUNCTION standoff.insert_bibliographic_entry (entry_key varchar(1023), entry_type varchar(20), fields standoff.bibliography_field[])
-- RETURNS VOID AS $$
-- BEGIN
--       WITH inserted AS (
--       INSERT INTO standoff.bibliography
--       (entry_key, entry_type) VALUES
--       ($entry_key, $entry_type)
--       RETURNING *)
--             INSERT INTO standoff.bibliography_field (bibliography_id, field_type, val) --VALUES
-- 	    SELECT (select bibliography_id from inserted), (a).field_type, (a).val
-- 	    FROM (SELECT unnest($fields) AS fld); -- x;
-- END;
-- $$ LANGUAGE SQL;

-- GRANT EXECUTE ON TABLE standoff.insert_bibliographic_entry
-- TO standoffadmin, standoffeditor, standoffuser;


CREATE TRIGGER bibliography_set_meta_on_insert BEFORE INSERT ON standoff.bibliography_field
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_insert();

CREATE TRIGGER bibliography_set_meta_on_update BEFORE UPDATE ON standoff.bibliography_field
    FOR EACH ROW EXECUTE PROCEDURE standoff.set_meta_on_update();

CREATE TRIGGER adjust_privilege_on_insert BEFORE INSERT ON standoff.bibliography_field
       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(484);

CREATE TRIGGER adjust_privilege_on_update BEFORE UPDATE ON standoff.bibliography_field
       FOR EACH ROW EXECUTE PROCEDURE standoff.adjust_privilege(484);


ALTER TABLE standoff.bibliography_field ENABLE ROW LEVEL SECURITY;

-- Note: We do bitwise AND on the integer value of privilege and then
-- test if it equals the bitmask. privilege & 16 = 16 is the same as
-- privilege & (1<<4) = (1<<4), which may be more readable. For
-- performance reasons we replace (1<<4) with the count itself.

CREATE POLICY allow_select ON standoff.bibliography_field FOR SELECT
USING (true);

CREATE POLICY assert_well_formed ON standoff.bibliography_field FOR INSERT TO standoffuser
WITH CHECK (created_by = current_user);

CREATE POLICY assert_well_formed_null ON standoff.bibliography_field FOR INSERT TO standoffuser
WITH CHECK (created_by is null); -- if null, then is set to
				 -- current_user by trigger.


-- FIXME: add rules

COMMIT;
