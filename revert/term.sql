-- Revert term

BEGIN;

DROP TRIGGER set_meta_on_insert ON standoff.term;
DROP TRIGGER set_meta_on_update ON standoff.term;

DROP TRIGGER adjust_privilege_on_insert ON standoff.term;
DROP TRIGGER adjust_privilege_on_update ON standoff.term;

REVOKE ALL PRIVILEGES ON TABLE standoff.term
       FROM standoffuser, standoffeditor, standoffadmin;

REVOKE ALL PRIVILEGES ON SEQUENCE standoff.term_term_id_seq
       FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.term;


COMMIT;
