-- Deploy application
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE standoff.application (
       application varchar not null,
       description text,
       PRIMARY KEY (application));

INSERT INTO standoff.application (application, description) VALUES
       ('markup', 'Markup is used to decorate a range of a document.'),
       ('relation', 'Relations are used interrelate markup.'),
       ('attribute', 'Attributes are assigned to markup.')
       ON CONFLICT DO NOTHING;


GRANT SELECT ON TABLE standoff.application TO standoffuser, standoffeditor, standoffadmin;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE standoff.application TO standoffadmin;

COMMIT;
