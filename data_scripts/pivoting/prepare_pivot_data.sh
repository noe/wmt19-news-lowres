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
   | grep -v '????' \
   | grep -v '\*\*\*\*' \
   | grep -v '++++++' \
   | grep -v '_ _ _ _' \
   | grep -v '\- \- \- \-' \
   | grep -v '= = = =' \
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
  ENRU_DOWNLOAD_DIR=$(realpath $DOWNLOAD_DIR/ru-en)
  ENRU_OUTPUT_DIR=$(realpath $OUTPUT_DIR/en-ru)

  mkdir -p $ENRU_OUTPUT_DIR

  cd $ENRU_DOWNLOAD_DIR

  # ORIGINAL CORPUS SIZE -------------------
  #
  #  23M united nations
  # 900K commoncrawl
  #  12M paracrawl
  #   1M yandex
  # ----------------------------------------


  declare -A corpus_sample_size=( ["en-ru/UNv1.0.en-ru"]=2000000 \
                                  ["commoncrawl.ru-en"]=200000 \
                                  ["paracrawl-release1.en-ru.zipporah0-dedup-clean"]=4000000 \
                                  ["corpus.en_ru.1m"]=1000000)
  # see hash tables in bash 4 at https://stackoverflow.com/a/3467959/674487

  TMP_CORPUS=$(mktemp)
  touch $TMP_CORPUS
  for corpus_prefix in "${!corpus_sample_size[@]}"; do
    clean_corpus_aggressive $corpus_prefix en ru clean
    paste $corpus_prefix.clean.en $corpus_prefix.clean.ru \
       | grep -v 'The time now is' \
       | sort -u \
       | clean_crawled_tsv \
       | shuf --random-source=<(get_seeded_random 777) \
       | head -"${corpus_sample_size[$corpus_prefix]}" >> $TMP_CORPUS
    rm $corpus_prefix.clean.en $corpus_prefix.clean.ru
  done  

  
  cat $TMP_CORPUS | shuf --random-source=<(get_seeded_random 111) -o $TMP_CORPUS

  cut -f 1 $TMP_CORPUS > $ENRU_OUTPUT_DIR/corpus.en-ru.en
  cut -f 2 $TMP_CORPUS > $ENRU_OUTPUT_DIR/corpus.en-ru.ru

  rm $TMP_CORPUS
}


# Prepare Kk-Ru data ##########################################################

prepare_kkru_data(){
  KKRU_DOWNLOAD_DIR=$(realpath $DOWNLOAD_DIR/kk-ru)
  KKRU_OUTPUT_DIR=$(realpath $OUTPUT_DIR/kk-ru)

  mkdir -p $KKRU_OUTPUT_DIR

  cd $KKRU_DOWNLOAD_DIR
  
  TMP_CRAWL_DIR=$(mktemp -d)
  mkdir -p $TMP_CRAWL_DIR

  $TMP_CRAWL_PREFIX=$TMP_CRAWL_DIR/crawl.kk-ru

  cut -f 1,2 crawl.kk-ru.tsv | sort -u | clean_crawled_tsv > $TMP_CRAWL_PREFIX.tsv
  cut -f 1 $TMP_CRAWL_PREFIX.tsv > $TMP_CRAWL_PREFIX.kk
  cut -f 2 $TMP_CRAWL_PREFIX.tsv > $TMP_CRAWL_PREFIX.ru

  clean_corpus_aggressive $TMP_CRAWL_PREFIX kk ru clean

  paste <(cat $TMP_CRAWL_PREFIX.kk) <(cat $TMP_CRAWL_PREFIX.ru) > $TMP_CRAWL_PREFIX.tsv
  cat $TMP_CRAWL_PREFIX.tsv news-commentary-v14.kk-ru.tsv \
       | sort -u \
       | shuf --random-source=<(get_seeded_random 333) \
       > $KKRU_OUTPUT_DIR

  rm -rf $TMP_CRAWL_DIR
}


prepare_enru_data
prepare_kkru_data

