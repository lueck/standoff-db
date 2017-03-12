#!/bin/sh

echo $(base64 $1),$(file --brief --mime-type $1),$(file --brief --mime-encoding $1),$1
