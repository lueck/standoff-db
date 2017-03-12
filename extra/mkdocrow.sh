#!/bin/sh
# Makes CSV from the file passed as first parameter:
#
# contents,mimetype,encoding,path
#
# where contents are base64 encoded.

echo $(base64 $1),$(file --brief --mime-type $1),$(file --brief --mime-encoding $1),$1
