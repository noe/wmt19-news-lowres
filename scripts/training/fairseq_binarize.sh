#!/bin/bash -x


: ${1:?"First argument is the source language"}
: ${2:?"Second argument is the target language"}
: ${3:?"Third argument is the training data prefix"}
: ${4:?"Fourth argument is the dev data prefix"}

SRC=$1
TGT=$2
TRAIN_PREFIX=$3
DEV_PREFIX=$4

. ~/.bash_profile

conda activate nlp_pytorch

VOCAB_SIZE=32000

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load common functions
. $SCRIPT_DIR/../generic/common.sh

TRAIN_DIR=$(dirname $TRAIN_PREFIX.$SRC)

BIN_DATA_DIR=$TRAIN_DIR/bin
mkdir -p $BIN_DATA_DIR

# Process each file
for LANG in $SRC $TGT
do
  log "Processing training [$LANG] data..."
  tokenize $LANG < $TRAIN_PREFIX.$LANG > $TRAIN_PREFIX.tok.$LANG
  train_truecaser $TRAIN_PREFIX.tok.$LANG $TRAIN_DIR/truecasing.$LANG
  truecase $TRAIN_DIR/truecasing.$LANG < $TRAIN_PREFIX.tok.$LANG > $TRAIN_PREFIX.tok.tc.$LANG

  log "Processing development [$LANG] data..."
  tokenize $LANG < $DEV_PREFIX.$LANG > $DEV_PREFIX.tok.$LANG
  truecase $TRAIN_DIR/truecasing.$LANG < $DEV_PREFIX.tok.$LANG > $DEV_PREFIX.tok.tc.$LANG
done

train_and_apply_bpe $TRAIN_DIR/bpe_codes $TRAIN_PREFIX.tok.tc $SRC $TGT $VOCAB_SIZE bpe
apply_bpe $TRAIN_DIR/bpe_codes $DEV_PREFIX.tok.tc $SRC $TGT bpe


# Binarize the dataset
fairseq-preprocess \
  --source-lang $SRC \
  --target-lang $TGT \
  --trainpref $TRAIN_PREFIX.tok.tc \
  --validpref $DEV_PREFIX.tok.tc \
  --testpref $DEV_PREFIX \
  --destdir $BIN_DATA_DIR \
  --thresholdtgt 0 \
  --thresholdsrc 0

