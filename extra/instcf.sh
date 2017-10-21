#!/bin/bash

set -e
# subsequent commands, that fail, will stop the script.

USAGE='Usage:
instcf.sh [-h | --help]                     Show this help.
instcf.sh DOCID TCFFILE [options to psql]   Insert the layers of 
                                            TCFFILE related to 
                                            document with DOCID
                                            into the database.

In the second form insdoc.sh inserts the layers of TCF file into a
POSTgreSQL database with a standoff schema installed. The plaintext
cell of the document is updated with the text layer, tokens are
inserted into the token table. [More layers will follow when the
schema is expanded.]

The related document must be indentified by its ID, which must be
passed as first parameter. The path to the TCF file must be passed as
second parameter. Subsequent parameters are passed to psql which is
used as database client.

Requirements: htcf must be installed. Its tcftokens and tcftokens
command line programs are used for parsing the TCF file into comma
separated values.

sed, the stream editor, must also be installed.

See also: psql(1), http://github.com/lueck/standoff-db,
http://github.com/lueck/htcf'

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

tmpsentences=$(tempfile -s .csv)

tmptokfreqs=$(tempfile -s .csv)

# We use SQL Interpolation. See psql docs. \\ is a command separator
# like semicolon.
textcommand="\\set txt \`tcflayer -rx ${infile}\` \\\\ UPDATE standoff.document SET plaintext = :'txt' WHERE document_id = ${DOCID};"

# write tokens to a temporary file
tcftokens -p --csv-delimiter $',' ${infile} |\
    sed "s/^/${DOCID},/g" > $tmptokens

tokencommand="\\copy standoff.token (document_id, token, token_number, text_range, source_range, postag, tagset, lemma, sentence_number) from '"$tmptokens"' WITH CSV DELIMITER ',' NULL AS '';"

# write sentences to a temporary file
tcflayer -sp --csv-delimiter $',' ${infile} |\
    sed "s/^\"[0-9 ]*\"/${DOCID}/g" > $tmpsentences

sentencecommand="\\copy standoff.sentence (document_id, sentence_number, text_range, source_range) from '"$tmpsentences"' WITH CSV DELIMITER ',' NULL AS '';"

#write token frequencies to a temporary file
corpusid=$(echo "select corpus_id from standoff.corpus_document cd left join standoff.corpus c using (corpus_id) where c.corpus_type='document' and cd.document_id=${DOCID};" | psql -tA $psqlopts)

tcffreq -tv --csv-delimiter $',' ${infile} |\
    sed "s/^/${corpusid},/g" > $tmptokfreqs 

tokfreqcommand="\\copy standoff.token_frequency (corpus_id, token, frequency) from '"$tmptokfreqs"' WITH CSV DELIMITER ',' NULL AS '';"


# do all that in a transaction
command="BEGIN; ${textcommand} ${sentencecommand} ${tokfreqcommand} ${tokencommand} COMMIT;"

#echo $command

# We cannot use --command=... here. See psql docs.
# echo $command | psql $psqlopts

psql -e ${psqlopts} <<EOF
BEGIN;
${textcommand}
${sentencecommand}
${tokfreqcommand}
${tokencommand}
COMMIT;
EOF

#rm $tmptokens
