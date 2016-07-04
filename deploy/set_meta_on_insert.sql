-- Deploy set_meta_on_insert
-- requires: arbschema
-- requires: arbroles

-- This function can be reused by triggers that update meta data on
-- insert or update. You can pass =gpriv= and =opriv= and =gid= as
-- static arguments.

BEGIN;

CREATE OR REPLACE FUNCTION arb.set_meta_on_insert()
    RETURNS TRIGGER AS $$
    BEGIN
    NEW.created_at = current_timestamp;
    NEW.created_by = current_user;
    RETURN NEW;
    END;
    $$ language 'plpgsql';

COMMIT;
