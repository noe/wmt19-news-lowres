#!/bin/bash


: ${1?"First argument is the directory where all data was downloaded"}
: ${2?"Second argument is the directory where the results will be placed"}

DOWNLOAD_DIR=$1
OUTPUT_DIR=$2
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MOSES_DIR=/home/usuaris/veu/noe.casas/wmt19_lowres/tools/moses-4.0
MOSES_SCRIPTS=$MOSES_DIR/scripts/
SEED=213

### Function to end the script with a message #################################
die() { echo "$*" 1>&2 ; exit 1; }


### Function to print a message to standard error #############################
log() { echo "$*" 1>&2; }


### Function to get a random number sequence ##################################
get_seeded_random(){
  # See https://www.gnu.org/software/coreutils/manual/html_node/Random-sources.html
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt \
    </dev/zero 2>/dev/null
}


### Function to tokenize and normalize punctuation of a file ##################
tokenize() {
  PREFIX=$1
  LANG=$2

  LANG_FLAG=$LANG
  if [ "$LANG" == "kk" ]; then
    LANG_FLAG=ru
  fi

  LC_ALL=C $MOSES_SCRIPTS/tokenizer/normalize-punctuation.perl -l $LANG_FLAG < $PREFIX.$LANG \
     | LC_ALL=C $MOSES_SCRIPTS/tokenizer/tokenizer.perl -q -no-escape -a -l $LANG_FLAG
}


### Function to clean a corpus ################################################
clean_corpus(){
 PREFIX=$1
 LANG1=$2
 LANG2=$3
 SUFFIX=$4
 MIN_LEN=2
 MAX_LEN=80
 LC_ALL=C $MOSES_SCRIPTS/training/clean-corpus-n.perl \
        $PREFIX $LANG1 $LANG2 $PREFIX.$SUFFIX $MIN_LEN $MAX_LEN $PREFIX.retained
}


### Function to train a truecasing model ######################################
train_truecaser(){
  FILE=$1
  MODEL=$2
  LC_ALL=C $MOSES_SCRIPTS/recaser/train-truecaser.perl -model $MODEL -corpus $FILE
}


### Function to apply a truecasing model ######################################
truecase(){
  FILE=$1
  MODEL=$2
  cat $FILE | LC_ALL=C $MOSES_SCRIPTS/recaser/truecase.perl -model $MODEL
}


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
sed 's,\(.*\)\t\(.*\)\t\(.*\)\t\(.*\)\t\(.*\),\1\t\2,g' $DOWNLOAD_DIR/train/kazakhtv.kk-en.tsv >> $TMP_TRAIN

# Include news commentary (reverse it to be kk-en)
sed 's,\(.*\)\t\(.*\),\2\t\1,g' $DOWNLOAD_DIR/train/news-commentary-v14-wmt19.en-kk.tsv >> $TMP_TRAIN

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
  tokenize $PREFIX $LANG > $PREFIX.tok.$LANG
  train_truecaser $PREFIX.tok.$LANG $OUTPUT_DIR/truecasing.$LANG
  truecase $PREFIX.tok.$LANG $OUTPUT_DIR/truecasing.$LANG > $PREFIX.tok.tc.$LANG
done

# Remove too long and too short sentences
log "Cleaning corpus..."
clean_corpus $PREFIX.tok.tc en kk clean

log "Training data is prepared at $PREFIX.tok.tc.clean.{en,kk}"

### Prepare test and development data #########################################



