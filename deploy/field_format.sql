-- Deploy arb-db:field_format to pg
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.field_format (
       field_format_id varchar(255) not null,
       regexp text DEFAULT '.*',
       PRIMARY KEY (field_format_id));

GRANT SELECT ON TABLE standoff.field_format
TO standoffeditor, standoffuser;

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE standoff.field_format
TO standoffadmin;

INSERT INTO standoff.field_format VALUES
       ('literal', '.*'),
       ('person', '.*'),
       ('year', '-?[0-9]{1,4}'),
       ('range', '.*')
       ON CONFLICT DO NOTHING;

COMMIT;
