-- Deploy language
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE arb.language (
       id varchar not null, -- abbrev: like en, de, fr
       PRIMARY KEY (id));

INSERT INTO arb.language VALUES
       ('en'),
       ('de'),
       ('fr'),
       ('nl');

COMMIT;
