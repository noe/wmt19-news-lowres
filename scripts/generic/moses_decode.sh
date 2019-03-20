#!/bin/bash


: ${1:?"First argument is the model directory"}
: ${2:?"Second argument is the target language"}

MODEL_DIR=$1
LANG=$2

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load common functions
. $SCRIPT_DIR/../generic/common.sh

moses_decode $MODEL_DIR $LANG

