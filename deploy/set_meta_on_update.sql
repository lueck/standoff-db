-- Deploy set_meta_on_update
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE FUNCTION standoff.set_meta_on_update()
    RETURNS TRIGGER AS $$
    BEGIN
    NEW.updated_at = current_timestamp;
    NEW.updated_by = coalesce(NEW.created_by, current_user);
    NEW.created_at = OLD.created_at;
    NEW.created_by = OLD.created_by;
    RETURN NEW;
    END;
    $$ language 'plpgsql';

COMMIT;
