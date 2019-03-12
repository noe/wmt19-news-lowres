#!/bin/bash -x


: ${1?"First argument is the directory where all data was downloaded"}
: ${2?"Second argument is the directory where the results will be placed"}

DOWNLOAD_DIR=$1
OUTPUT_DIR=$2
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SEED=3211

# load common functions
. $SCRIPT_DIR/../generic/common.sh


clean_crawled_tsv(){
  grep -v '____' \
   | grep -v '\-\-\-\-' \
   | $SCRIPT_DIR/filter_numeric.py --tsv --max-ratio 0.2
}

clean_corpus_aggressive(){
  local PREFIX=$1
  local LANG1=$2
  local LANG2=$3
  local SUFFIX=$4
  local MIN_LEN=5
  local MAX_LEN=80
  # local RETAINED=$PREFIX.retained
  local RETAINED=""
  LC_ALL=C $MOSES_SCRIPTS/training/clean-corpus-n.perl -ratio 3 \
        $PREFIX $LANG1 $LANG2 $PREFIX.$SUFFIX $MIN_LEN $MAX_LEN $RETAINED
}


# Prepare En-Ru data ##########################################################

prepare_enru_data(){
  ENRU_DOWNLOAD_DIR=$DOWNLOAD_DIR/ru-en

  cd $ENRU_DOWNLOAD_DIR

  clean_corpus_aggressive en-ru/UNv1.0.en-ru en ru clean
  clean_corpus_aggressive commoncrawl.ru-en en ru clean
  clean_corpus_aggressive paracrawl-release1.en-ru.zipporah0-dedup-clean en ru clean
  clean_corpus_aggressive corpus.en_ru.1m en ru clean

  EN_FILES=en-ru/UNv1.0.en-ru.clean.en commoncrawl.ru-en.clean.en paracrawl-release1.en-ru.zipporah0-dedup-clean.clean.en corpus.en_ru.1m.clean.en
  RU_FILES=en-ru/UNv1.0.en-ru.clean.ru commoncrawl.ru-en.clean.ru paracrawl-release1.en-ru.zipporah0-dedup-clean.clean.ru corpus.en_ru.1m.clean.ru

  TMP_FILE=$(mktemp)
  paste <(cat $EN_FILES) <(cat $RU_FILES) \
       | clean_crawled_tsv \
       | shuf --random-source=<(get_seeded_random 111) \
       > $TMP_FILE

  cut -f 1 > $OUTPUT_DIR/corpus.en-ru.en
  cut -f 2 > $OUTPUT_DIR/corpus.en-ru.ru

  rm $EN_FILES $RU_FILES $TMP_FILE
}


# Prepare Kk-Ru data ##########################################################

prepare_kkru_data(){
  KKRU_DOWNLOAD_DIR=$DOWNLOAD_DIR/kk-ru
  # TODO
  cut -f 1,2 crawl.kk-ru.tsv | sort -u
  news-commentary-v14.kk-ru.tsv.gz
}


prepare_enru_data

