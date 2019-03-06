#!/bin/bash


get_seeded_random(){
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt \
    </dev/zero 2>/dev/null
}


deterministic_shuf_split(){
  SEED=$1
  FILE=$2
  TMP_FILE=$(mktemp)
  cat $FILE | shuf --random-source=<(get_seeded_random $SEED) > $TMP_FILE
  head -1566 $TMP_FILE > dev.$FILE
  tail -n+1567 $TMP_FILE > test.$FILE
  rm $TMP_FILE
}


deterministic_shuf_split 42 newsdev2019.tc.en
deterministic_shuf_split 42 newsdev2019.tc.kk

