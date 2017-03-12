#!/bin/bash

set -e
# subsequent commands, that fail, will stop the script.

USAGE='Usage:
insdoc.sh [-h | --help]            Show this help.
insdoc.sh FILE [options to psql]   Insert FILE into document table.

In the second form insdoc.sh inserts a document into a POSTgreSQL
database with a standoff schema installed. The document path must be
passed as first parameter. Subsequent parameters are passed to psql
which is used as database client.

See also: man (1) psql'

die()
{
    echo -e "$1" >&$2
    exit $3
}

case "$1" in
    -h | --help)
	die "$USAGE" 1 0 ;;
esac

if [ -f $1 ]; then
    infile=$1
else
    die "File not found: $1\\n\\n$USAGE" 2 1
fi

shift

psqlopts=$@

#echo "Options to psql: "$psqlopts

tmpfile=$(tempfile)

./mkdocrow.sh $infile > $tmpfile

command="\\copy standoff.document (source_base64, mimetype, source_charset, source_uri) from '"${tmpfile}"' delimiter ',' CSV";

psql -c "$command" $psqlopts

rm $tmpfile
