-- Deploy language
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE standoff.language (
       id varchar not null, -- abbrev: like en, de, fr
       PRIMARY KEY (id));

INSERT INTO standoff.language VALUES
       ('en'),
       ('de'),
       ('fr'),
       ('nl');

COMMIT;
