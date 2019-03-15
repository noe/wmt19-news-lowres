#!/bin/bash -x


: ${1:?"First argument is the model directory"}
: ${2:?"Second argument is the data prefix"}
: ${3:?"Third argument is the source language"}
: ${4:?"Fourth argument is the target language"}
MODEL_DIR=$1
DATA_PREFIX=$2
SRC=$3
TGT=$4


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load common functions
. $SCRIPT_DIR/../generic/common.sh


train_moses $MODEL_DIR $DATA_PREFIX $SRC $TGT 32000
