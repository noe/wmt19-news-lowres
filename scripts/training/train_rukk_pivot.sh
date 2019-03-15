#!/bin/bash -x


: ${1:?"First argument is the model directory"}
: ${2:?"Second argument is the training data prefix"}
: ${3:?"Second argument is the dev data prefix"}
: ${4:?"Third argument is the source language"}
: ${5:?"Fourth argument is the target language"}
MODEL_DIR=$1
TRAIN_DATA_PREFIX=$2
DEV_DATA_PREFIX=$3
SRC=$4
TGT=$5


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load common functions
. $SCRIPT_DIR/../generic/common.sh


train_moses $MODEL_DIR $TRAIN_DATA_PREFIX $DEV_DATA_PREFIX $SRC $TGT 32000
