-- Deploy arb-db:field_format to pg
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.field_format (
       field_format varchar(20) not null,
       regexp text DEFAULT '.*',
       PRIMARY KEY (field_format));

GRANT SELECT ON TABLE standoff.field_format
TO standoffeditor, standoffuser;

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE standoff.field_format
TO standoffadmin;

INSERT INTO standoff.field_format VALUES
       ('literal', '.*'),
       ('person', '.*'),
       ('year', '-?[0-9]{1,4}'),
       ('date', '.*'), -- TODO
       ('range', '.*'),
       ('pagination', '(page|column|line|verse|section|paragraph)'),
       ('editortype', '(editor|compiler|founder|continuator|redactor|reviser|collaborator|organizer)'),
       ('language', '.*'),
       ('month', '[0-9]{1,2}'), -- TODO
       ('integer', '[0-9]+'),
       ('pubstate', '(inpreparation|submitted|forthcoming|inpress|prepublished)'),
       ('type', '(conference|electronic|masterthesis|phdthesis|techreport|www)'),
       ('uri', '.*'), -- TODO
       ('gender', '(sf|sm|sn|pf|pm|pn|pp)')
       ON CONFLICT DO NOTHING;

COMMIT;
