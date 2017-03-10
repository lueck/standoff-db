-- Revert token_frequency

BEGIN;

DROP TRIGGER inc_token_frequency ON standoff.token;
DROP FUNCTION standoff.inc_token_frequency_on_token_insert();

DROP TRIGGER inc_token_frequency ON standoff.corpus_document;
DROP FUNCTION standoff.inc_token_frequency_on_corpus_document_insert();

DROP FUNCTION standoff.inc_token_frequency(doc integer, tok text);


DROP TRIGGER dec_token_frequency ON standoff.token;
DROP FUNCTION standoff.dec_token_frequency_on_token_delete();

DROP TRIGGER dec_token_frequency ON standoff.corpus_document;
DROP FUNCTION standoff.dec_token_frequency_on_corpus_document_delete();

DROP FUNCTION standoff.dec_token_frequency(doc integer, tok text);


REVOKE ALL PRIVILEGES ON TABLE standoff.token_frequency
       FROM standoffuser, standoffeditor, standoffadmin;

DROP TABLE standoff.token_frequency;

COMMIT;
