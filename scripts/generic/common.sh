

SUBWORD_NMT_DIR=/home/usuaris/veu/noe.casas/wmt19_lowres/tools/subword-nmt
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
  local LANG=$1
  local LANG_FLAG=$LANG
  if [ "$LANG" == "kk" ]; then
    LANG_FLAG=ru
  fi

  LC_ALL=C $MOSES_SCRIPTS/tokenizer/normalize-punctuation.perl -l $LANG_FLAG \
     | LC_ALL=C $MOSES_SCRIPTS/tokenizer/tokenizer.perl -q -no-escape -a -l $LANG_FLAG
}


### Function to detokenize ####################################################
detokenize(){
  local LANG=$1
  local LANG_FLAG=$LANG
  if [ "$LANG" == "kk" ]; then
    LANG_FLAG=ru
  fi

  LC_ALL=C $MOSES_SCRIPTS/tokenizer/detokenizer.perl -l $LANG_FLAG 2> /dev/null
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
  local MODEL=$1
  # it works also with cyrillic script
  LC_ALL=C $MOSES_SCRIPTS/recaser/truecase.perl -model $MODEL
}


### Function to de-truecase ###################################################
detruecase(){
  LC_ALL=C $MOSES_SCRIPTS/recaser/detruecase.perl
}


#### Function to compute simple stuff #########################################
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

### Function to train and apply BPE to a source and target corpora ############
train_and_apply_bpe(){
  local BPE_CODES_PREFIX=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4
  local VOCAB_SIZE=$5
  local SUFFIX=$6

  mkdir -p $(dirname $BPE_CODES_PREFIX)

  for LANG in $SRC $TGT; do
    cat $DATA_PREFIX.$LANG \
       | $SUBWORD_NMT_DIR/subword_nmt/learn_bpe.py -s $VOCAB_SIZE \
       > $BPE_CODES_PREFIX.$LANG

    $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py -c $BPE_CODES_PREFIX.$LANG \
       < $DATA_PREFIX.$LANG \
       > ${DATA_PREFIX}.${SUFFIX}.${LANG}
  done
}

### Function to apply BPE to a source and target corpora #####################
apply_bpe(){
  local BPE_CODES_PREFIX=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4
  local SUFFIX=$5

  for LANG in $SRC $TGT; do
    $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py -c $BPE_CODES_PREFIX.$LANG \
       < $DATA_PREFIX.$LANG \
       > ${DATA_PREFIX}.${SUFFIX}.${LANG}
  done
}


### Function to train a language model of the target language #################
### (it uses KenLM) ###########################################################
train_lm(){
  local MODEL_DIR=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4
  local NGRAM_ORDER=$5

  mkdir -p $MODEL_DIR/lm

  $MOSES_DIR/bin/lmplz -o $NGRAM_ORDER < $DATA_PREFIX.$TGT > $MODEL_DIR/lm/lm.arpa.$TGT
  $MOSES_DIR/bin/build_binary $MODEL_DIR/lm/lm.arpa.$TGT $MODEL_DIR/lm/lm.blm.$TGT
}


### Function to train a Moses translation model ###############################
train_translation(){
  local MODEL_DIR=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4
  local NGRAM_ORDER=$5

  mkdir -p $MODEL_DIR/model

  local MODEL_DIR=$(realpath $MODEL_DIR)

  # Factor is 0 unless you do something with factored translation models
  local FACTOR=0

  # Type 8 --> KenLM
  local LM_TYPE=8

  local LM_FILE=$MODEL_DIR/lm/lm.blm.$TGT

  LC_ALL=C $MOSES_SCRIPTS/training/train-model.perl \
     -root-dir $MODEL_DIR \
     -corpus $(realpath $DATA_PREFIX) \
     -f $SRC -e $TGT \
     -alignment grow-diag-final-and \
     -reordering msd-bidirectional-fe \
     -lm $FACTOR:$NGRAM_ORDER:$LM_FILE:$LM_TYPE \
     -external-bin-dir $MOSES_DIR/tools \
     -mgiza \
     >& $MODEL_DIR/training.out
}


### Function to tune a Moses model ############################################
tuning(){
  local MODEL_DIR=$1
  local DATA_PREFIX=$2
  local SRC=$3
  local TGT=$4

  mkdir -p $MODEL_DIR/model
  mkdir -p $MODEL_DIR/tuning

  LC_ALL=C $MOSES_SCRIPTS/training/mert-moses.pl \
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


### Function to reduce the size of the phrase table ##########################
### (see http://www.statmt.org/moses/?n=Advanced.RuleTables#ntoc3)
compact_phrase_table(){
  local MODEL_DIR=$1
  $MOSES_DIR/bin/processPhraseTableMin \
      -in $MODEL_DIR/model/phrase-table.gz \
      -out $MODEL_DIR/model/phrase-table \
      -nscores 4 -threads 4
  sed 's,phrase-table.gz,phrase-table.minphr,g' -i $MODEL_DIR/model/moses.ini
  sed 's,PhraseDictionaryMemory,PhraseDictionaryCompact,g' -i $MODEL_DIR/model/moses.ini
}

### Function to escape in-place chars that are special to Moses ##############
escape_special_chars(){
  local FILE=$1
  if [ "$FILE" == "" ]; then
    $MOSES_SCRIPTS/tokenizer/escape-special-chars.perl
  else
    local TMP_FILE=$(mktemp)
    $MOSES_SCRIPTS/tokenizer/escape-special-chars.perl < $FILE > $TMP_FILE
    mv $TMP_FILE $FILE
  fi
}

### Function to train a Moses system end-to-end ##############################
train_moses(){
  local MODEL_DIR=$1
  local TRAIN_DATA_PREFIX=$2
  local DEV_DATA_PREFIX=$3
  local SRC=$4
  local TGT=$5
  local VOCAB_SIZE=$6
  local TOKEN_GRANULARITY=${7:-"subword"}

  # Order is the size of N-grams to be used. Here we use a bit longer ngrams
  # because we are using subwords
  local NGRAM_ORDER=${8:-6}

  mkdir -p $MODEL_DIR

  local SRC_TRUECASING_MODEL=$(dirname $TRAIN_DATA_PREFIX)/truecasing.$SRC
  test -e $SRC_TRUECASING_MODEL && cp $SRC_TRUECASING_MODEL $MODEL_DIR/

  ## Note : DATA MUST BE ALREADY TOKENIZED AND TRUECASED BEFORE THIS

  if [ "$TOKEN_GRANULARITY" == "subword" ]; then
    log "Training BPE..."
    train_and_apply_bpe $MODEL_DIR/bpe_codes $TRAIN_DATA_PREFIX $SRC $TGT $VOCAB_SIZE bpe
    apply_bpe $MODEL_DIR/bpe_codes $DEV_DATA_PREFIX $SRC $TGT bpe
    TRAIN_DATA_PREFIX=${TRAIN_DATA_PREFIX}.bpe
    DEV_DATA_PREFIX=${DEV_DATA_PREFIX}.bpe
  fi

  log "Cleaning corpus (again)..."
  # Clean again after BPE to ensure mgiza does not find any sentence with ratio > 9
  LC_ALL=C $MOSES_SCRIPTS/training/clean-corpus-n.perl -ratio 6 \
        ${TRAIN_DATA_PREFIX} $SRC $TGT ${TRAIN_DATA_PREFIX}.clean 2 80

  escape_special_chars ${TRAIN_DATA_PREFIX}.clean.${SRC}
  escape_special_chars ${TRAIN_DATA_PREFIX}.clean.${TGT}

  log "Training Language Model..."
  train_lm $MODEL_DIR ${TRAIN_DATA_PREFIX}.clean $SRC $TGT $NGRAM_ORDER

  log "Training Translation Model..."
  train_translation $MODEL_DIR ${TRAIN_DATA_PREFIX}.clean $SRC $TGT $NGRAM_ORDER

  log "Tuning..."
  tuning $MODEL_DIR ${DEV_DATA_PREFIX} $SRC $TGT

  log "Compacting phrase table..."
  # Using subwords needs larger ngram order, which leads to larger phrase
  # table. We should compact it in order not to consume A LOT of memory.
  compact_phrase_table $MODEL_DIR

  log "Done."
}


### Function to apply BPE or not depending on TOKEN_GRANULARITY ###############
maybe_bpe(){
  local MODEL_DIR=$1
  local LANG=$2
  local TOKEN_GRANULARITY=$3

  if [ "$TOKEN_GRANULARITY" == "subword" ]; then
    $SUBWORD_NMT_DIR/subword_nmt/apply_bpe.py -c $MODEL_DIR/bpe_codes.$LANG
  else
    cat
  fi
}


### Function to decode using a Moses engine ###################################
moses_decode(){
  local MODEL_DIR=$1
  local SRC=$2
  local TGT=$3
  local TOKEN_GRANULARITY=${4:-"subword"}

  local INI_FILE=$MODEL_DIR/model/moses.ini

  local SRC_TRUECASING_MODEL=$MODEL_DIR/truecasing.$SRC

  test -e $SRC_TRUECASING_MODEL || die "Source lang truecasing model $SRC_TRUECASING_MODEL not present."

  tokenize $SRC \
     | truecase $SRC_TRUECASING_MODEL \
     | maybe_bpe $MODEL_DIR $SRC $TOKEN_GRANULARITY \
     | escape_special_chars \
     | $MOSES_DIR/bin/moses -f $INI_FILE -threads 12  2> /dev/null \
     | sed 's, @-@ ,-,g' \
     | sed -r 's/(@@ )|(@@ ?$)//g' \
     | detokenize $TGT \
     | detruecase
}

