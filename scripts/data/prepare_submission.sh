#!/bin/bash

: ${1:?"First argument is the source language"}
: ${2:?"Second argument is the source SGM file"}
: ${3:?"Third argument is the target language"}
: ${4:?"Fourth argument is the hypothesis text file"}


SRC=$1
SRC_SGM=$2
TGT=$3
TGT_TXT=$4

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load common functions
. $SCRIPT_DIR/../generic/common.sh


WRAP_INTO_SGM=$MOSES_SCRIPTS/ems/support/wrap-xml.perl


cat $TGT_TXT \
   |detokenize $TGT \
   | detruecase \
   | $WRAP_INTO_SGM $TGT $SRC_SGM > $TGT_TXT.sgm

