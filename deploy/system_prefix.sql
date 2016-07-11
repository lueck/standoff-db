-- Deploy system_prefix
-- requires: arbschema
-- requires: arbroles

BEGIN;

CREATE TABLE IF NOT EXISTS standoff.system_prefix (
	namespace varchar not null,
	prefix varchar not null,
	PRIMARY KEY (prefix),
	UNIQUE (namespace));


GRANT SELECT ON standoff.system_prefix TO standoffuser;

GRANT SELECT, INSERT, UPDATE, DELETE ON standoff.system_prefix
      TO standoffeditor, standoffadmin;

COMMIT;
