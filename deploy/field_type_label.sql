-- Deploy arb-db:field_type_label to pg
-- requires: arbschema
-- requires: arbroles
-- requires: field_type

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.field_type_label (
       field_type varchar(20) not null references standoff.field_type,
       language varchar not null references standoff.language,
       label text not null,
       description text,
       UNIQUE (field_type, language));

GRANT SELECT ON TABLE standoff.field_type_label
TO standoffeditor, standoffuser;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE standoff.field_type_label
TO standoffadmin;


INSERT INTO standoff.field_type_label
       (language, field_type, label, description) VALUES
('en', 'abstract', 'Abstract',
''),
('en', 'addendum', 'Addendum',
''),
('en', 'afterword', 'Afterword',
''),
('en', 'annotation', 'Annotation',
''),
('en', 'annotator', 'Annotator',
''),
('en', 'author', 'Author',
''),
-- ('en', 'authortype', '', ''),
('en', 'bookauthor', 'Book''s Author',
''),
('en', 'bookpagination', 'Book''s Pagination Scheme',
''),
('en', 'booksubtitle', 'Book''s Subtitle',
''),
('en', 'booktitle', 'Book''s Title',
''),
('en', 'booktitleaddon', 'Addon to the Book''s Title',
''),
('en', 'chapter', 'Chapter',
''),
('en', 'commentator', 'Commentator',
''),
('en', 'date', 'Date',
''),
('en', 'doi', 'DOI',
''),
('en', 'edition', 'Edition',
''),
('en', 'editor', 'Editor',
''),
('en', 'editora', 'Editor a',
''),
('en', 'editoratype', 'Editor a Type',
''),
('en', 'editorb', 'Editor b',
''),
('en', 'editorbtype', 'Editor b Type',
''),
('en', 'editorc', 'Editor c',
''),
('en', 'editorctype', 'Editor c Type',
''),
('en', 'editortype', 'Editor Type',
''),
('en', 'eid', 'Electronic ID',
''),
('en', 'entrysubtype', 'Entry Subtype',
''),
('en', 'eprint', 'Eprint',
''),
('en', 'eprintclass', 'Eprint Class',
''),
('en', 'eprinttype', 'Eprint Type',
''),
('en', 'eventdate', 'Event Date',
''),
('en', 'eventtitle', 'Event Title',
''),
('en', 'eventtitleaddon', 'Event Title Addon',
''),
-- ('en', 'file', '', ''),
('en', 'foreword', 'Foreword',
''),
('en', 'holder', 'Holder',
''),
('en', 'howpublished', 'How Published',
''),
('en', 'indextitle', 'Index Title',
''),
('en', 'institution', 'Institution',
''),
('en', 'introduction', 'Introduction',
''),
('en', 'isan', 'ISAN',
''),
('en', 'isbn', 'ISBN',
''),
('en', 'ismn', 'ISMN',
''),
('en', 'isrn', 'ISRN',
''),
('en', 'issn', 'ISSN',
''),
('en', 'issue', 'Issue',
''),
('en', 'issuesubtitle', 'Issue Subtitle',
''),
('en', 'iswc', 'ISWC',
''),
('en', 'journalsubtitle', 'Journal Subtitle',
''),
('en', 'journaltitle', 'Journal Title',
''),
('en', 'journaltitleaddon', 'Journal Title Addon',
''),
('en', 'label', 'Label',
''),
('en', 'language', 'Language',
''),
('en', 'library', 'Library',
''),
('en', 'location', 'Location',
''),
('en', 'mainsubtitle', 'Main Subtitle',
''),
('en', 'maintitle', 'Main Title',
''),
('en', 'maintitleaddon', 'Main Title Addon',
''),
('en', 'month', 'Month',
''),
('en', 'nameaddon', 'Name Addon',
''),
('en', 'note', 'Note',
''),
('en', 'number', 'Number',
''),
('en', 'organization', 'Organization',
''),
('en', 'origauthor', 'Orig. Author',
''),
('en', 'origdate', 'Orig. Date',
''), -- Not in biblatex
('en', 'origlanguage', 'Orig. Language',
''),
('en', 'origlocation', 'Orig. Location',
''),
('en', 'origpublisher', 'Orig. Publisher',
''),
('en', 'origtitle', 'Orig. Title',
''),
-- ('en', 'origyear', '', ''),
('en', 'pages', 'Pages',
''),
('en', 'pagetotal', 'Page Total',
''),
('en', 'pagination', 'Pagination Scheme',
''),
('en', 'part', 'Part',
''),
('en', 'publisher', 'Publisher',
''),
('en', 'pubstate', 'Pubstate',
''),
('en', 'reprinttitle', 'Reprint Title',
''),
('en', 'series', 'Series',
''),
-- ('en', 'shortauthor', '', ''),
-- ('en', 'shorteditor', '', ''),
-- ('en', 'shorthand', '', ''),
-- ('en', 'shorthandintro', '', ''),
-- ('en', 'shortjournal', '', ''),
-- ('en', 'shortseries', '', ''),
-- ('en', 'shorttitle', '', ''),
('en', 'subtitle', 'Subtitle',
''),
('en', 'title', 'Title',
''),
('en', 'titleaddon', 'Title Addon',
''),
('en', 'translator', 'Translator',
''),
('en', 'type', 'Type',
''),
('en', 'url', 'URL',
''),
('en', 'urldate', 'URL Date',
''),
('en', 'venue', 'Venue',
''),
('en', 'version', 'Version',
''),
('en', 'volume', 'Volume',
''),
('en', 'volumes', 'Volumes',
''),
('en', 'year', 'Year',
''),
-- SPECIAL FIELDS
('en', 'gender', 'Gender',
'');



COMMIT;