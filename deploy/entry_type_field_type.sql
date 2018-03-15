-- Deploy arb-db:entry_type_field_type to pg
-- requires: arbschema
-- requires: arbroles
-- requires: entry_type
-- requires: field_type

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.entry_type_field_type (
       entry_type varchar(20) not null references standoff.entry_type,
       field_type varchar(20) not null references standoff.field_type,
       weight integer not null DEFAULT 2000,
       PRIMARY KEY (entry_type, field_type));

GRANT SELECT ON TABLE standoff.entry_type_field_type
TO standoffeditor, standoffuser;

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE standoff.entry_type_field_type
TO standoffadmin;

INSERT INTO standoff.entry_type_field_type (entry_type, field_type, weight)
VALUES
('book', 'author', 1),
('book', 'title', 2),
('book', 'subtitle', 3),
('book', 'titleaddon', 4),
('book', 'location', 20),
('book', 'publisher', 20),
('book', 'year', 22),
('book', 'edition', 23),
('book', 'language', 30),

('book', 'note', 80),
('book', 'addendum', 81),

('book', 'origtitle', 100),
('book', 'origlocation', 101),
('book', 'origpublisher', 102),
('book', 'origdate', 103),
('book', 'origauthor', 104),
('book', 'origlanguage', 108),

('book', 'doi', 200),
('book', 'eprint', 201),
('book', 'eprintclass', 202),
('book', 'eprinttype', 203),
('book', 'url', 204),
('book', 'urldate', 205),
('book', 'isbn', 206),

('book', 'editor', 1000),
('book', 'translator', 1001),
('book', 'annotator', 1002),
('book', 'commentator', 1003),
('book', 'introduction', 1004),
('book', 'foreword', 1005),
('book', 'afterword', 1006),
('book', 'editortype', 1007),

('book', 'editora', 1010),
('book', 'editoratype', 1011),
('book', 'editorb', 1012),
('book', 'editorbtype', 1013),
('book', 'editorc', 1014),
('book', 'editorctype', 1015),

('book', 'maintitle', 1020),
('book', 'mainsubtitle', 1021),
('book', 'maintitleaddon', 1022),
('book', 'volume', 1023),
('book', 'part', 1024),
('book', 'volumes', 1025),
('book', 'series', 1026),
('book', 'number', 1027),
('book', 'chapter', 1028),
('book', 'pages', 1029),
('book', 'pagetotal', 1030),
('book', 'pubstate', 1031),
('book', 'gender', 1032);














COMMIT;
