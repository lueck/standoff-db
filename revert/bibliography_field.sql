-- Revert bibliography_field from pg

BEGIN;

DROP POLICY IF EXISTS allow_select ON standoff.bibliography_field;
DROP POLICY IF EXISTS assert_well_formed ON standoff.bibliography_field;
DROP POLICY IF EXISTS assert_well_formed_null ON standoff.bibliography_field;

REVOKE ALL PRIVILEGES ON TABLE standoff.bibliography_field
FROM standoffadmin, standoffeditor, standoffuser;

-- REVOKE ALL PRIVILEGES ON FUNCTION standoff.insert_bibliographic_entry(varchar(1023), varchar(20), fields standoff.bibliograpyh_field[])
-- FROM standoffadmin, standoffeditor, standoffuser;

-- DROP FUNCTION standoff.insert_bibliographic_entry(varchar(1023), varchar(20), fields standoff.bibliograpyh_field[]);

DROP TRIGGER bibliography_set_meta_on_update ON standoff.bibliography_field;

DROP TRIGGER bibliography_set_meta_on_insert ON standoff.bibliography_field;

DROP TRIGGER adjust_privilege_on_insert ON standoff.bibliography_field;

DROP TRIGGER adjust_privilege_on_update ON standoff.bibliography_field;

DROP TABLE IF EXISTS standoff.bibliography_field;

COMMIT;
