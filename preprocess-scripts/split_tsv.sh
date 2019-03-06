#!/bin/bash

TSV_FILE='../utils/kazakhtv.kk-en.tsv'
SOURCE_SIDE='../utils/kazakhtv.kk-en.kk'
TARGET_SIDE='../utils/kazakhtv.kk-en.en'

sed 's,\t.*,,g' $TSV_FILE > $SOURCE_SIDE
sed 's,.*\t,,g' $TSV_FILE > $TARGET_SIDE

