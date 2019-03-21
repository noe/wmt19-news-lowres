#!/bin/bash

: ${1:?"First argument is the model directory"}
: ${2:?"Second argument is the source language"}
: ${3:?"Third argument is the target language"}

MODEL_DIR=$1
SRC=$2
TGT=$3
TOKEN_GRANULARITY=${4:-"subword"}


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load common functions
. $SCRIPT_DIR/../generic/common.sh

moses_decode $MODEL_DIR $SRC $TGT $TOKEN_GRANULARITY

