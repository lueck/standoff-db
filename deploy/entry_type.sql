-- Deploy entry_type
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.entry_type (
       entry_type varchar(20) not null,
       weight integer not null DEFAULT 2000,	
       PRIMARY KEY (entry_type));

GRANT SELECT ON TABLE standoff.entry_type
TO standoffeditor, standoffuser;

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE standoff.entry_type
TO standoffadmin;


INSERT INTO standoff.entry_type VALUES
       ('article', 20),
       ('book', 10),
       ('mvbook', 31),
       ('inbook', 32),
       ('bookinbook', 33),
       ('suppbook', 34),
       ('booklet', 106),
       ('collection', 80),
       ('mvcollection', 81),
       ('incollection', 82),
       ('suppcollection', 83),
       ('manual', 100),
       ('misc', 1000),
       ('online', 102),
       ('patent', 103),
       ('periodical', 200),
       ('suppperiodical', 201),
       ('procedings', 230),
       ('mvprocedings', 231),
       ('inprocedings', 232),
       ('reference', 51),
       ('mvreference', 52),
       ('inreference', 50),
       ('report', 101),
       ('set', 2000),
       ('thesis', 104),
       ('unpublished', 105),
       ('xdata', 2001);

COMMIT;
