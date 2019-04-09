#!/bin/bash

: ${1:?"First argument is the final data directory"}
: ${2:?"First argument is the output directory"}


DATA_DIR=$(realpath $1)
OUTPUT_DIR=$2

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load common functions
. $SCRIPT_DIR/../generic/common.sh


SGM_TO_TEXT="LC_ALL=C $MOSES_SCRIPTS/ems/support/input-from-sgm.perl"

mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR

wget http://data.statmt.org/wmt19/translation-task/test-ts.tgz
tar xzvf test-ts.tgz

$SGM_TO_TEXT < test/newstest2019-enkk-src-ts.en.sgm > newstest2019-enkk.en
$SGM_TO_TEXT < test/newstest2019-kken-src-ts.kk.sgm > newstest2019-kken.kk

cat newstest2019-enkk.en \
     | tokenize en \
     | truecase $DATA_DIR/enkk/truecasing.en \
     | $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py -c $DATA_DIR/enkk/bpe_codes.en \
     > newstest2019-enkk.tok.tc.bpe.en

cat newstest2019-kken.kk \
     | tokenize kk \
     | truecase $DATA_DIR/kken/truecasing.kk \
     | $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py -c $DATA_DIR/kken/bpe_codes.kk \
     > newstest2019-kken.tok.tc.bpe.kk

rm -rf test-ts.tgz test
