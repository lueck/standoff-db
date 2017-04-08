-- Revert document_range

BEGIN;

DROP INDEX standoff.document_range_text_range_idx;

DROP INDEX standoff.document_range_source_range_idx;

DROP INDEX standoff.document_range_document_idx;

REVOKE ALL PRIVILEGES ON TABLE standoff.document_range
FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.document_range;

COMMIT;
