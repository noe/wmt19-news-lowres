#!/bin/bash

######################################################################
#                                                                    #
#  Just as example, I'm not sure if this code works now in calcula   #
#                                                                    #
######################################################################

MOSES_BIN=/veu4/usuaris31/xtrans/mosesdecoder/bin
SCRIPTS_ROOTDIR=/veu4/usuaris31/xtrans/mosesdecoder/scripts/
MOSES_SCRIPTS=/veu4/usuaris31/xtrans/mosesdecoder/scripts/
WORKING_DIR=/veu4/usuaris31/cescola/wmt17/de-en/final/moses/
SRILM_DIR=/veu4/usuaris31/xtrans/srilm/bin/i686-m64/
SOURCE_LANG='en'
TARGET_LANG='de'
TEST_FILE='newstest2014'
DEV_FILE='dev'


srilm(){

mkdir -p $WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/lm/

    $SRILM_DIR/ngram-count -interpolate -kndiscount -order 5 -text $WORKING_DIR/train/train.${TARGET_LANG}  -lm $WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/lm/words.lm.${TARGET_LANG}

}

training(){

$SCRIPTS_ROOTDIR/training/train-model.perl \
    -external-bin-dir /veu4/usuaris31/xtrans/mgiza/mgizapp/bin/  -mgiza \
    --corpus $WORKING_DIR/train/train \
    --alignment grow-diag-final-and \
    --score-options '--GoodTuring' \
    --root-dir $WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/ \
    --f ${SOURCE_LANG} --e ${TARGET_LANG} \
    --lm 0:5:$WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/lm/words.lm.${TARGET_LANG}:0 \
    --translation-factors 0-0 \
    --reordering msd-bidirectional-fe \
    --reordering-factors 0-0 
}


tuning(){

$MOSES_SCRIPTS/training/mert-moses.pl $WORKING_DIR/dev/${DEV_FILE}.${SOURCE_LANG} $WORKING_DIR/dev/${DEV_FILE}.${TARGET_LANG} /veu4/usuaris31/xtrans/mosesdecoder/moses-cmd/bin/gcc-4.8.3/release/debug-symbols-on/link-static/threading-multi/moses  $WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/model/moses.ini --nbest 100 --working-dir $WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/tuning/  --rootdir $MOSES_SCRIPTS --mertdir $MOSES_BIN -threads 24 --filtercmd '/veu4/usuaris31/moses/mosesdecoder/scripts/training/filter-model-given-input.pl' --decoder-flags "-drop-unknown -mbr -threads 24 -mp -v 0"

#./reuse-weights.perl $WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/tuning/moses.ini < $WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/model/moses.ini > $WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/tuning/moses.weight-reused.ini


}


EvalTest(){
    RAM_DIR=$WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/test14
    FILTERED_DIR=$RAM_DIR/filtered_test

  	
    mkdir $WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/test
   

    $SCRIPTS_ROOTDIR/training/filter-model-given-input.pl $FILTERED_DIR $WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/tuning/moses.ini $WORKING_DIR/test/${TEST_FILE}.${SOURCE_LANG} 
    
#    ./reuse-weights.perl $WORKING_DIR/baseline-${SOURCE_LANG}${TARGET_LANG}/tuning/moses.weight-reused.ini < $FILTERED_DIR/moses.ini > $FILTERED_DIR/moses.test.ini

    $MOSES_BIN/moses -drop-unknown -mbr  -mp -config ${FILTERED_DIR}/moses.ini  -input-file $WORKING_DIR/test/${TEST_FILE}.${SOURCE_LANG}  > $RAM_DIR/testout #2> /dev/null

    $SCRIPTS_ROOTDIR/generic/multi-bleu.perl $WORKING_DIR/test/${TEST_FILE}.${TARGET_LANG}  < $RAM_DIR/testout  >  $RAM_DIR/test.EVAL
  
    cat $RAM_DIR/test.EVAL


}


#
srilm

#
training

#
tuning

#
EvalTest

