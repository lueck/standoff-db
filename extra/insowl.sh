#!/bin/bash

set -e
# subsequent commands, that fail, will stop the script.

USAGE='Usage:
insowl.sh [-h | --help]            Show this help.
insowl.sh FILE [options to psql]   Insert FILE into document table.

In the second form insowl.sh inserts a OWL annotation schema into a
POSTgreSQL database with a standoff schema installed. The OWL file
path must be passed as first parameter. Subsequent parameters are
passed to psql which is used as database client.

See also: psql(1), http://github.com/lueck/standoff-db'

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

tmp_dir=$(mktemp -d)
tmp_ontology=$tmp_dir/ontology.csv
tmp_resources=$tmp_dir/resources.csv
tmp_ontology_id=$tmp_dir/ontology_id.dat

standoff owl2csv -o $infile > $tmp_ontology
standoff owl2csv -r $infile > $tmp_resources

touch $tmp_ontology_id

# FIXME: Do this in one transaction and roll back on error.

ontology_command="\\copy standoff.ontology (iri, namespace_delimiter, prefix, version_info, definition) from '"${tmp_ontology}"' delimiter ',' CSV; SELECT currval('standoff.ontology_id_seq');";

ont_id=$(echo $ontology_command | psql -t $psqlopts)

#sed -i "s/^/${ont_id},/g" $tmp_ontology 

resource_command="\\copy standoff.term (ontology, local_name, application) from program 'sed \"s/^/"${ont_id}",/g\" "${tmp_resources}"' delimiter ',' CSV;"

echo $resource_command | psql -t $psqlopts

rm -rf $tmp_dir
