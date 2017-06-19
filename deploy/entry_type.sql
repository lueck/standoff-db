-- Deploy entry_type
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.entry_type (
        entry_type varchar(20) not null,
        PRIMARY KEY (entry_type));

INSERT INTO standoff.entry_type VALUES
       ('article'),
       ('book'),
       ('mvbook'),
       ('inbook'),
       ('bookinbook'),
       ('suppbook'),
       ('booklet'),
       ('collection'),
       ('mvcollection'),
       ('incollection'),
       ('suppcollection'),
       ('manual'),
       ('misc'),
       ('online'),
       ('patent'),
       ('periodical'),
       ('suppperiodical'),
       ('procedings'),
       ('mvprocedings'),
       ('inprocedings'),
       ('reference'),
       ('mvreference'),
       ('inreference'),
       ('report'),
       ('set'),
       ('thesis'),
       ('unpublished'),
       ('xdata');

COMMIT;
