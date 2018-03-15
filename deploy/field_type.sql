-- Deploy arb-db:field_type to pg
-- requires: arbschema
-- requires: arbroles
-- requires: field_format

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.field_type (
       field_type_id varchar(255) NOT NULL,
       field_format_id varchar(255) NOT NULL REFERENCES standoff.field_format DEFAULT 'literal',
       PRIMARY KEY (field_type_id));

GRANT SELECT ON TABLE standoff.field_type
TO standoffeditor, standoffuser;

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE standoff.field_type
TO standoffadmin;

INSERT INTO standoff.field_type VALUES
       ('author', 'person'),
       ('editor', 'person'),
       ('title', 'literal'),
       ('subtitle', 'literal'),
       ('title_addon', 'literal'),
       ('location', 'literal'),
       ('publisher', 'literal'),
       ('year', 'year'),
       ('origyear', 'year'),
       ('origtitle', 'literal'),
       ('origauthor', 'person'),
       ('journal_title', 'literal'),
       ('journal_subtitle', 'literal'),
       ('journal_title_addon', 'literal'),
       ('volume', 'literal'),
       ('number', 'literal'),
       ('issue', 'literal'),
       ('pages', 'range'),
       ('chapter', 'literal'),
       ('book_title', 'literal'),
       ('book_subtitle', 'literal'),
       ('book_title_addon', 'literal'),
       ('main_title', 'literal'),
       ('main_subtitle', 'literal'),
       ('main_title_addon', 'literal'),
       ('note', 'literal'),
       ('addendum', 'literal'),
       ('translator', 'person'),
       ('introduction', 'person'),
       ('afterword', 'person'),
       ('annotator', 'person'),
       ('bookauthor', 'person'),
       ('commentator', 'person'),
       ('edition', 'literal')
       ON CONFLICT DO NOTHING;


COMMIT;
