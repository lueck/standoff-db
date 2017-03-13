# Database relations for stand-off annotations and basic text mining #

State: Under construction and still keeps changing. Not ready for
production yet. We do not yet use the deployment-tool's tag system.

## Features ##

- Relations for documents and for grouping them in user defined
  corpora and for a global corpus.

- Basic text mining functionality: relations for tokens, for
  frequencies of tokens per corpus (user defined, global and per
  document), for the absolute count of tokens in a corpus, with and
  without deduplication. Relations for lemmas, sentences and POStags
  will follow soon.

- Relations for standoff annotations (external markup) that reference
  the document (source) by character offsets.

- Discontinuous markup, RDF-like relations between markup ranges,
  attributes on markup.

- Stand-off annotations and tokens both have columns for character
  offsets, so that they can be interrelated. - Use your annotations
  for text mining.
  
- Two types of character offsets of markup, tokens etc.: a) in
  relation to the source file, b) in relation to the plaintext
  separated from the source. Have a look at
  [htcf](http://github.com/lueck/htcf), which is a tokenizer, that
  outputs tokens with these two types of character offsets, and which
  is also a command line program for getting
  [WebLicht](http://weblicht.sfs.uni-tuebingen.de/weblichtwiki/index.php/Main_Page)'s
  TCF files into the database.

- The `document` relation makes it possible to collect text in various
  input formats, which are stored base64 encoded. Plain text formats
  like `text/plaintext` or `text/xml` can be viewed as decoded text in
  a view called `text_document`. Column `plaintext` for text layer
  like in TCF.

- Relations for bibliography/meta data.

- Row level security and unix-like groups and privileges for hiding
  and sharing documents, corpora, annotations etc.

- Everything lives in a schema called `standoff`.

- Makes no assumption about user management and authentication. I use
  the role management of the RDBMS.

- Makes no assumption about application. Plain SQL.

- `bash` scripts for inserting documents and for getting TCF files
  into the relations.

## Requirements ##

- [PostgreSQL](https://www.postgresql.org/) >= 9.5: Even if you plan
  to work on a remote database, you will at least need a local `psql`
  client. The required database extensions `pgcrypt` and `uuid-ossp`
  are contained in the `postgres-contrib-VERSION` package provided by
  the [pgdg](https://www.postgresql.org/download/).
  
- [Sqitch](http://sqitch.org): Database migration tool required for
  deployment.

- [pgTAP](http://pgtap.org/): Required for running tests, contained in
  the `postgresql-VERSION-pgtap` package provided by the
  [pgdg](https://www.postgresql.org/download/).

- [git](https://git-scm.com/): Required only if you plan to further
  develop this database schema using `sqitch`.

- [PostgREST](http://postgrest.com/): Required if you want to expose
  the database as a RESTful webservice.


After cloning this repository, configure `sqitch`.

	cd standoff-db
	sqitch config --user user.name 'Your Name'
	sqitch config --user user.email 'your@email.org'
	sqitch config --bool deploy.verify true
	sqitch config --bool rebase.verify true

## Testing ##

Running unit tests should be done on a non-production
database. `arb_test` is defined as `sqitch`'s default target. `pgtap`
is needed as an extension.

	createdb arb_test
	psql -d arb_test -c "CREATE EXTENSION pgtap;"
	cd <PATH TO standoff-db>
	sqitch deploy
	pg_prove -d arb_test test/*.sql

## RESTful webservice ##

PostgREST makes it easy to expose the database schema through through a
RESTful web api. After installation run

	postgrest postgres://standoffrest:$RESTPASS@localhost/arb_test -a standoffanon --schema 'standoff'

Note:

Before exposing this to the web, you should definitively read the docs
of [PostgREST](http://postgrest.com/admin/security/).


## Deployment ##

After defining a production target, you can tell `sqitch` to deploy the
schema there.

	sqitch target add production db:pg://[user]:[pass]@[rds url]:5432/[dbname]
	sqitch -t production deploy

## Docs ##

Read the unit tests in `test/*.sql`.
