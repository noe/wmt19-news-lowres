
MOSES_DIR=/home/usuaris/veu/noe.casas/wmt19_lowres/tools/moses-4.0
MOSES_SCRIPTS=$MOSES_DIR/scripts/


### Function to end the script with a message #################################
die() { echo "$*" 1>&2 ; exit 1; }


### Function to print a message to standard error #############################
log() { echo "$*" 1>&2; }


### Function to get a random number sequence ##################################
get_seeded_random(){
  # See https://www.gnu.org/software/coreutils/manual/html_node/Random-sources.html
  seed="$1"
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
  LC_ALL=C $MOSES_SCRIPTS/training/clean-corpus-n.perl \
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
