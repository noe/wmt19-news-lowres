#!/bin/bash -x


: ${1:?"First argument is the data directory"}
: ${2:?"Second argument is the output prefix"}


DATA_DIR=$1
OUTPUT_PREFIX=$2

SEED=1221

SYNTH_PREFIX=$DATA_DIR/synthetic/kk-en/synthetic_kk-en
PARALLEL_PREFIX=$DATA_DIR/baselines/train.tok.tc.clean

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load common functions
. $SCRIPT_DIR/../generic/common.sh


# Oversample parallel data
PARALLEL_EN="$PARALLEL_PREFIX.en $PARALLEL_PREFIX.en $PARALLEL_PREFIX.en"
PARALLEL_KK="$PARALLEL_PREFIX.kk $PARALLEL_PREFIX.kk $PARALLEL_PREFIX.kk"


TMP_DIR=$(mktemp -d)
mkdir -p $TMP_DIR
TMP_PREFIX=$TMP_DIR/train.kken

# English is tokenized both in the parallel data and in the synthetic one
cat $PARALLEL_EN $SYNTH_PREFIX.en | detokenize en > $TMP_PREFIX.en

cat $PARALLEL_KK $SYNTH_PREFIX.kk | sed 's, @-@ ,-,g' > $TMP_PREFIX.kk

shuf --random-source=<(get_seeded_random $SEED) -o $TMP_PREFIX.en < $TMP_PREFIX.en
shuf --random-source=<(get_seeded_random $SEED) -o $TMP_PREFIX.kk < $TMP_PREFIX.kk

mv $TMP_PREFIX.en $OUTPUT_PREFIX.en
mv $TMP_PREFIX.kk $OUTPUT_PREFIX.kk

rmdir $TMP_DIR
