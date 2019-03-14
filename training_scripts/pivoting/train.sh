#!/bin/bash -x


SUBWORD_NMT_DIR=/home/usuaris/veu/noe.casas/wmt19_lowres/tools/subword-nmt
MOSES_DIR=/home/usuaris/veu/noe.casas/wmt19_lowres/tools/moses-4.0
MOSES_SCRIPTS=$MOSES_DIR/scripts/


### Function to end the script with a message #################################
die() { echo "$*" 1>&2 ; exit 1; }


### Function to print a message to standard error #############################
log() { echo "$*" 1>&2; }


train_and_apply_bpe(){
  local MODEL_DIR=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4
  local JOINT_VOCAB_SIZE=$5
  local SUFFIX=$6

  mkdir -p $MODEL_DIR

  BPE_CODES=$MODEL_DIR/bpe_codes

  cat $DATA_PREFIX.$SRC $DATA_PREFIX.$TGT \
     | $SUBWORD_NMT_DIR/subword_nmt/learn_bpe.py --symbols $JOINT_VOCAB_SIZE \
     > $BPE_CODES

  $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py -c $BPE_CODES \
     < $DATA_PREFIX.$SRC \
     > $DATA_PREFIX.$SUFFIX.$SRC

  $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py -c $BPE_CODES \
     < $DATA_PREFIX.$TGT \
     > $DATA_PREFIX.$SUFFIX.$TGT
}


train_lm(){
  local MODEL_DIR=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4

  mkdir -p $MODEL_DIR/lm

  $MOSES_DIR/bin/lmplz -o 3 < $DATA_PREFIX.$TGT > $MODEL_DIR/lm/lm.arpa.$TGT
  $MOSES_DIR/bin/build_binary $MODEL_DIR/lm.arpa.en $MODEL_DIR/lm/lm.blm.$TGT
}

train_translation(){
  local MODEL_DIR=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4

  mkdir -p $MODEL_DIR/model

  $MOSES_SCRIPTS/training/train-model.perl \
     -root-dir $MODEL_DIR \
     -corpus $DATA_PREFIX \
     -f $SRC -e $TGT \
     -alignment grow-diag-final-and \
     --score-options '--GoodTuring' \
     -reordering msd-bidirectional-fe \
     -reorderig-factors 0-0 \
     -translation-factors 0-0 \
     -lm 0:3:$MODEL_DIR/lm/lm.blm.$TGT:8 \
     -external-bin-dir $MOSES_DIR/tools \
     -mgiza \
     >& $MODEL_DIR/training.out
}

tuning(){
  local MODEL_DIR=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4

  mkdir -p $MODEL_DIR/model
  mkdir -p $MODEL_DIR/tuning

  $MOSES_SCRIPTS/training/mert-moses.pl \
      $DATA_PREFIX.$SRC $DATA_PREFIX.$TGT \
      $MOSES_DIR/moses $MODEL_DIR/model/moses.ini \
      --working-dir $MODEL_DIR/tuning \
      --nbest 100 \
      --mertdir $MOSES_DIR/bin/ \
      --rootdir $MOSES_SCRIPTS \
      -threads 16 \
      --decoder-flags "-drop-unknown -mbr -threads 24 -mp -v 0" \
      &> $MODEL_DIR/mert.out & 
}

train_moses(){
  local MODEL_DIR=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4
  local JOINT_VOCAB_SIZE=$5

  train_and_apply_bpe $MODEL_DIR $DATA_PREFIX $SRC $TGT $JOINT_VOCAB_SIZE bpe
  #train_lm $MODEL_DIR ${DATA_PREFIX}.bpe $SRC $TGT
  #train_translation $MODEL_DIR ${DATA_PREFIX}.bpe $SRC $TGT
  #tuning $MODEL_DIR ${DATA_PREFIX}.bpe $SRC $TGT
}

: ${1:?"First argument is the model directory"}
: ${2:?"Second argument is the data prefix"}
: ${3:?"Third argument is the source language"}
: ${4:?"Fourth argument is the target language"}
MODEL_DIR=$1
DATA_PREFIX=$2
SRC=$3
TGT=$4

train_moses $MODEL_DIR $DATA_PREFIX $SRC $TGT 40000
