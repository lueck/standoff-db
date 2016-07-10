-- Deploy arbroles
-- requires: arbschema

BEGIN;

CREATE ROLE standoffuser NOLOGIN NOINHERIT;
CREATE ROLE standoffeditor NOLOGIN NOINHERIT;
CREATE ROLE standoffadmin NOLOGIN NOINHERIT CREATEROLE;

GRANT USAGE ON SCHEMA standoff TO standoffuser, standoffeditor, standoffadmin;
GRANT SELECT ON ALL TABLES IN SCHEMA standoff TO standoffuser, standoffeditor, standoffadmin;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA standoff TO standoffadmin;

COMMIT;
