#!/bin/bash

set -e
# subsequent commands, that fail, will stop the script.

USAGE='Usage:
instcf.sh [-h | --help]                     Show this help.
instcf.sh DOCID TCFFILE [options to psql]   Insert the layers of 
                                            TCFFILE related to 
                                            document with DOCID
                                            into the database.

In the second form instcf.sh inserts the layers of TCF file into a
PostgreSQL database with a standoff schema installed. Tokens,
sentences, POStags and lemmas are inserted into the token table. [More
layers will follow when the schema is expanded.]

The related document must be indentified by its ID, which must be
passed as first parameter. The path to the TCF file must be passed as
second parameter. Subsequent parameters are passed to psql which is
used as database client.

Requirements: pytcf must be installed. Its tcf2csv command line
program is used for parsing the TCF file into comma separated values.

sed, the stream editor, must also be installed.

See also: psql(1), http://github.com/lueck/standoff-db,
http://github.com/lueck/pytcf'

die()
{
    echo -e "$1" >&$2
    exit $3
}

case "$1" in
    -h | --help)
	die "$USAGE" 1 0 ;;
esac

DOCID=$1

if [ -f $2 ]; then
    infile=$2
else
    die "File not found: $1\\n\\n$USAGE" 2 1
fi

shift
shift

psqlopts=$@

#echo "Options to psql: "$psqlopts

tmptokens=$(tempfile -s .csv)

# tmptokfreqs=$(tempfile -s .csv)

# We use SQL Interpolation. See psql docs. \\ is a command separator
# like semicolon.
# textcommand="\\set txt \`tcflayer -rx ${infile}\` \\\\ UPDATE standoff.document SET plaintext = :'txt' WHERE document_id = ${DOCID};"

# write tokens to a temporary file
#tcftokens -p --csv-delimiter $',' ${infile} |\
#    sed "s/^/${DOCID},/g" > $tmptokens

tcf2csv --no-header --fields 'token tokenNum POStag lemma sentenceNum numInSentence' $infile |\
    sed "s/^/${DOCID},/g" > $tmptokens


tokencommand="\\copy standoff.token (document_id, token, token_number, postag, lemma, sentence, number_in_sentence) from '"$tmptokens"' WITH CSV DELIMITER ',' NULL AS '';"


# do all that in a transaction
#command="BEGIN; ${textcommand} ${sentencecommand} ${tokfreqcommand} ${tokencommand} COMMIT;"

# We cannot use --command=... here. See psql docs.
# echo $command | psql $psqlopts

psql -e ${psqlopts} <<EOF
BEGIN;
-- ${textcommand}
-- ${sentencecommand}
-- ${tokfreqcommand}
${tokencommand}
COMMIT;
EOF

rm $tmptokens
# rm $tmpsentences
# rm $tmptokfreqs
