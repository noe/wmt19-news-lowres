#!/bin/bash


MOSES_DIR=/home/usuaris/veu/noe.casas/wmt19_lowres/tools/moses-4.0
MOSES_SCRIPTS=$MOSES_DIR/scripts/


### Function to end the script with a message #################################
die() { echo "$*" 1>&2 ; exit 1; }


### Function to print a message to standard error #############################
log() { echo "$*" 1>&2; }


train_lm(){
  local MODEL_DIR=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4

  mkdir -p $MODEL_DIR/lm

  $MOSES_DIR/bin/lmplz -o 3 < $DATA_PREFIX.$TGT > $MODEL_DIR/lm/lm.arpa.$TGT
  $MOSES_DIR/bin/build_binary $MODEL_DIR/lm.arpa.en $MODEL_DIR/lm/lm.blm.$TGT
}

train_tm(){
  local MODEL_DIR=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4

  mkdir -p $MODEL_DIR

  $MOSES_SCRIPTS/training/train-model.perl \
     -root-dir $MODEL_DIR \
     -corpus $DATA_PREFIX \
     -f $SRC -e $TGT \
     -alignment grow-diag-final-and \
     -reordering msd-bidirectional-fe \
     -lm 0:3:$MODEL_DIR/lm/lm.blm.$TGT:8 \
     -external-bin-dir $MOSES_DIR/tools >& $MODEL_DIR/training.out
}

tuning(){
  local MODEL_DIR=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4

  mkdir -p $MODEL_DIR

  $MOSES_SCRIPTS/training/mert-moses.pl \
      $DATA_PREFIX.$SRC $DATA_PREFIX.$TGT \
      $MOSES_DIR/moses $MODEL_DIR/model/moses.ini --mertdir $MOSES_DIR/bin/ \
      &> $MODEL_DIR/mert.out & 
}
