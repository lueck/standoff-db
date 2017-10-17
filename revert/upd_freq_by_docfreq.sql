-- Revert upd_freq_by_docfreq

BEGIN;

DROP TRIGGER add_token_frequency ON standoff.token_frequency;
DROP FUNCTION standoff.add_token_frequency_on_frequency_insert();

DROP TRIGGER add_token_frequency ON standoff.corpus_document;
DROP FUNCTION standoff.add_token_frequency_on_corpus_document_insert();

DROP FUNCTION standoff.add_token_frequency_to_corpus(integer, text, integer);

DROP FUNCTION standoff.add_token_frequency_each_corpus(doc integer, tok text, freq integer);


DROP TRIGGER substract_token_frequency ON standoff.token_frequency;
DROP FUNCTION standoff.substract_token_frequency_on_token_frequency_delete();

DROP TRIGGER d30_substract_token_frequency ON standoff.corpus_document;
DROP FUNCTION standoff.substract_token_frequency_on_corpus_document_delete();

DROP FUNCTION standoff.substract_token_frequency_each_corpus(doc integer, tok text, freq integer);

DROP FUNCTION IF EXISTS standoff.substract_token_frequency_from_corpus(corps integer, tok text, freq integer);

COMMIT;
