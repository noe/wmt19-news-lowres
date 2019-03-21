#!/bin/bash


: ${1:?"First argument is the model directory"}
: ${2:?"Second argument is the data root"}
MODEL_DIR=$1
DATA_ROOT=$2


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load common functions
. $SCRIPT_DIR/../generic/common.sh

TRAIN_DATA_PREFIX=$DATA_ROOT/baselines/train.tok.tc.clean
DEV_DATA_PREFIX=$DATA_ROOT/baselines/dev.tok.tc
SRC=en
TGT=kk

train_moses $MODEL_DIR $TRAIN_DATA_PREFIX $DEV_DATA_PREFIX $SRC $TGT 10000 word
