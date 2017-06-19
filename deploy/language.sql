-- Deploy language
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE standoff.language (
       language varchar not null, -- abbrev: like en, de, fr
       PRIMARY KEY (language));

INSERT INTO standoff.language VALUES
       ('en'),
       ('de'),
       ('fr'),
       ('nl');

COMMIT;
