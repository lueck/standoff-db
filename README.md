# Database relations for stand-off markup #

## Requirements ##

- [PostgreSQL](https://www.postgresql.org/) >= 9.5: Even if you plan
  to work on a remote database, you will at least need a local `psql`
  client. The required database extensions `pgcrypt` and `uuid-ossp`
  are contained in the `postgres-contrib-VERSION` package provided by
  the [pgdg](https://www.postgresql.org/download/).
  
- [Sqitch](http://sqitch.org): Database migration tool required for
  deploying.

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
	sqitch deploy
	pg_prove -d arb_test test/*.sql

## RESTful webservice ##

PostgREST make it easy to expose the database schema through through a
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
