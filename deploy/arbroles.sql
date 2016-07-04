-- Deploy arbroles
-- requires: arbschema

BEGIN;

CREATE ROLE arbuser NOLOGIN NOINHERIT;
CREATE ROLE arbeditor NOLOGIN NOINHERIT;
CREATE ROLE arbadmin NOLOGIN NOINHERIT CREATEROLE;

GRANT USAGE ON SCHEMA arb TO arbuser, arbeditor, arbadmin;
GRANT SELECT ON ALL TABLES IN SCHEMA arb TO arbuser, arbeditor, arbadmin;

COMMIT;
