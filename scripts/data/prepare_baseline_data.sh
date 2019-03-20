#!/bin/bash


: ${1?"First argument is the directory where all data was downloaded"}
: ${2?"Second argument is the directory where the results will be placed"}

DOWNLOAD_DIR=$1
OUTPUT_DIR=$2
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SEED=213
GENERATE_TEST_DEV=$SCRIPT_DIR/../generic/generate_test_dev.sh

# load common functions
. $SCRIPT_DIR/../generic/common.sh

############ MAIN #############################################################


### Ensure the download and output directories exist and are correct ##########
test -d $DOWNLOAD_DIR/train || die "Directory $DOWNLOAD_DIR/train does not exist"
test -d $DOWNLOAD_DIR/dev || die "Directory $DOWNLOAD_DIR/dev does not exist"
mkdir -p $OUTPUT_DIR


### Prepare training data #####################################################

# Use a temporary file to collect the data
log "Gathering training data..."
TMP_TRAIN=$(mktemp)
touch $TMP_TRAIN

# Include Kazakh TV dataset
cut -f 1,2 $DOWNLOAD_DIR/train/kk-en/kazakhtv.kk-en.tsv | sort -u >> $TMP_TRAIN

# Include news commentary (reverse it to be kk-en)
sed 's,\(.*\)\t\(.*\),\2\t\1,g' $DOWNLOAD_DIR/train/kk-en/news-commentary-v14-wmt19.en-kk.tsv | sort -u >> $TMP_TRAIN

# We exclude wikititles due to its very poor quality
# cat $DOWNLOAD_DIR/train/wikititles-v1.kk-en.tsv >> $TMP_TRAIN

# Shuffle file in place
cat $TMP_TRAIN | shuf --random-source=<(get_seeded_random $SEED) -o $TMP_TRAIN

# Extract source and target sides
PREFIX=$OUTPUT_DIR/train
sed 's,\t.*,,g' $TMP_TRAIN > $PREFIX.kk
sed 's,.*\t,,g' $TMP_TRAIN > $PREFIX.en

# Remove temporary file
rm $TMP_TRAIN

# Process each file
for LANG in en kk
do
  log "Processing training [$LANG] data..."
  tokenize $LANG < $PREFIX.$LANG > $PREFIX.tok.$LANG
  rm $PREFIX.$LANG
  train_truecaser $PREFIX.tok.$LANG $OUTPUT_DIR/truecasing.$LANG
  truecase $OUTPUT_DIR/truecasing.$LANG < $PREFIX.tok.$LANG > $PREFIX.tok.tc.$LANG
  rm $PREFIX.tok.$LANG
done

# Remove too long and too short sentences
log "Cleaning corpus..."
clean_corpus $PREFIX.tok.tc en kk clean
rm $PREFIX.tok.tc.{en,kk}

log "*** Training data is prepared at $PREFIX.tok.tc.clean.{en,kk}"


### Function to split development at test set #################################
deterministic_shuf_split(){
  local SEED=$1
  local PREFIX=$2
  local LANG=$3
  local TMP_FILE=$(mktemp)
  cat $PREFIX.$LANG | shuf --random-source=<(get_seeded_random $SEED) > $TMP_FILE
  head -1566 $TMP_FILE > $OUTPUT_DIR/dev.tok.tc.$LANG
  tail -n+1567 $TMP_FILE > $OUTPUT_DIR/test.tok.tc.$LANG
  rm $TMP_FILE
}

### Prepare test and development data #########################################

DEVTEST_PREFIX=$OUTPUT_DIR/dev_test

log "Extracting text from SGM files..."
cat $DOWNLOAD_DIR/dev/newsdev2019-kken-ref.en.sgm \
   | LC_ALL=C $MOSES_SCRIPTS/ems/support/input-from-sgm.perl \
   > $DEVTEST_PREFIX.en

cat $DOWNLOAD_DIR/dev/newsdev2019-kken-src.kk.sgm \
   | LC_ALL=C $MOSES_SCRIPTS/ems/support/input-from-sgm.perl \
   > $DEVTEST_PREFIX.kk


for LANG in en kk
do
  log "Processing dev/test [$LANG] data..."
  tokenize $LANG < $DEVTEST_PREFIX.$LANG > $DEVTEST_PREFIX.tok.$LANG
  rm $DEVTEST_PREFIX.$LANG
  truecase $OUTPUT_DIR/truecasing.$LANG < $DEVTEST_PREFIX.tok.$LANG > $DEVTEST_PREFIX.tok.tc.$LANG
  rm $DEVTEST_PREFIX.tok.$LANG
done

log "Splitting test and dev sets..."
deterministic_shuf_split 42 $DEVTEST_PREFIX.tok.tc kk
deterministic_shuf_split 42 $DEVTEST_PREFIX.tok.tc en
rm $DEVTEST_PREFIX.tok.tc.{en,kk}

log "*** Development data is prepared at $OUTPUT_DIR/dev.tok.tc.{en,kk}"
log "*** Test data is prepared at $OUTPUT_DIR/test.tok.tc.{en,kk}"

