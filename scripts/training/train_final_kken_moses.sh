#!/bin/bash


: ${1:?"First argument is the model directory"}
: ${2:?"Second argument is the data directory"}
MODEL_DIR=$1
DATA_DIR=$2


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load common functions
. $SCRIPT_DIR/../generic/common.sh

TRAIN_DATA_PREFIX=$DATA_DIR/train_kken.tok.tc
DEV_DATA_PREFIX=$DATA_DIR/dev.tok.tc
SRC=kk
TGT=en

train_moses $MODEL_DIR $TRAIN_DATA_PREFIX $DEV_DATA_PREFIX $SRC $TGT x word 3
