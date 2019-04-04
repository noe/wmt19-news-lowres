#!/bin/bash

. ~/.bash_profile

conda activate nlp_pytorch

SRC=${1:?"First argument is the source language"}
TGT=${2:?"Second argument is the target language"}
TRAIN_PREFIX=${3:?"Third argument is the training data prefix"}
DEV_PREFIX=${4:?"Fourth argument is the dev data prefix"}
BIN_DATA_DIR=${5:?"Sixth argument is the output data directory"}

# Binarize the dataset
fairseq-preprocess \
  --source-lang $SRC \
  --target-lang $TGT \
  --trainpref $TRAIN_PREFIX \
  --validpref $DEV_PREFIX \
  --testpref $DEV_PREFIX \
  --destdir $BIN_DATA_DIR \
  --thresholdtgt 0 \
  --thresholdsrc 0

