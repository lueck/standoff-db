-- Deploy arb-db:bibliography_field to pg
-- requires: arbschema
-- requires: arbroles
-- requires: bibliography
-- requires: field_type

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.bibliography_field (
       bibliography_id uuid not null REFERENCES standoff.bibliography,
       field_type varchar(20) not null REFERENCES standoff.entry_type,
       val text not null,
       created_at timestamp not null,
       created_by varchar not null,
       updated_at timestamp,
       updated_by varchar,
       gid varchar,
       privilege integer not null DEFAULT 509,
       UNIQUE (bibliography_id, field_type));

GRANT INSERT, UPDATE, DELETE, SELECT ON TABLE standoff.bibliography_field
TO standoffadmin, standoffeditor, standoffuser;


COMMIT;
