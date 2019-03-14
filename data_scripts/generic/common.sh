
MOSES_DIR=/home/usuaris/veu/noe.casas/wmt19_lowres/tools/moses-4.0
MOSES_SCRIPTS=$MOSES_DIR/scripts/


### Function to end the script with a message #################################
die() { echo "$*" 1>&2 ; exit 1; }


### Function to print a message to standard error #############################
log() { echo "$*" 1>&2; }


### Function to get a random number sequence ##################################
get_seeded_random(){
  # See https://www.gnu.org/software/coreutils/manual/html_node/Random-sources.html
  local seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt </dev/zero 2>/dev/null
}


### Function to tokenize and normalize punctuation of a file ##################
tokenize(){
  local PREFIX=$1
  local LANG=$2
  local LANG_FLAG=$LANG
  if [ "$LANG" == "kk" ]; then
    LANG_FLAG=ru
  fi

  LC_ALL=C $MOSES_SCRIPTS/tokenizer/normalize-punctuation.perl -l $LANG_FLAG < $PREFIX.$LANG \
     | LC_ALL=C $MOSES_SCRIPTS/tokenizer/tokenizer.perl -q -no-escape -a -l $LANG_FLAG
}


### Function to clean a corpus ################################################
clean_corpus(){
  local PREFIX=$1
  local LANG1=$2
  local LANG2=$3
  local SUFFIX=$4
  local MIN_LEN=2
  local MAX_LEN=80
  # local RETAINED=$PREFIX.retained
  local RETAINED=""
  LC_ALL=C $MOSES_SCRIPTS/training/clean-corpus-n.perl -ratio 5 \
        $PREFIX $LANG1 $LANG2 $PREFIX.$SUFFIX $MIN_LEN $MAX_LEN $RETAINED
}


### Function to train a truecasing model ######################################
train_truecaser(){
  local FILE=$1
  local MODEL=$2
  # it works also with cyrillic script
  LC_ALL=C $MOSES_SCRIPTS/recaser/train-truecaser.perl -model $MODEL -corpus $FILE
}


### Function to apply a truecasing model ######################################
truecase(){
  local FILE=$1
  local MODEL=$2
  # it works also with cyrillic script
  cat $FILE | LC_ALL=C $MOSES_SCRIPTS/recaser/truecase.perl -model $MODEL
}


#### Function to compute simple stuff ##############################
compute() {
    if hash bc 2>/dev/null; then
        echo "$@" | bc
    else
        die 'Command "bc" is not available'
    fi
}


### Function to split a TSV corpus into training, dev and test sets ###########
### (add suffixes to results: .train, .dev, .test)
split_tsv_train_dev_test (){
    local TSV_FILE=$1
    local OUTPUT_PREFIX=$2
    local SRC=$3
    local TGT=$4
    local DEV_LINES=$5
    local TEST_LINES=$6

    local TMP_TRAIN=$(mktemp)
    local TMP_DEV=$(mktemp)
    local TMP_TEST=$(mktemp)

    local TOTAL_LINES=$(cat ${TSV_FILE} | wc -l)
    local TRAIN_LINES=$(compute "${TOTAL_LINES} - ${DEV_LINES} -${TEST_LINES}")

    head -${TEST_LINES} ${TSV_FILE} > "${TMP_TEST}"
    tail -n+$(compute "${TEST_LINES} + 1") ${TSV_FILE} | head -${DEV_LINES} > "${TMP_DEV}"
    tail -${TRAIN_LINES} ${TSV_FILE} > "${TMP_TRAIN}"

    cut -f 1 $TMP_TRAIN > $OUTPUT_PREFIX.train.$SRC
    cut -f 2 $TMP_TRAIN > $OUTPUT_PREFIX.train.$TGT

    cut -f 1 $TMP_DEV > $OUTPUT_PREFIX.dev.$SRC
    cut -f 2 $TMP_DEV > $OUTPUT_PREFIX.dev.$TGT

    cut -f 1 $TMP_TEST > $OUTPUT_PREFIX.test.$SRC
    cut -f 2 $TMP_TEST > $OUTPUT_PREFIX.test.$TGT

    rm $TMP_TRAIN $TMP_DEV $TMP_TEST
}

