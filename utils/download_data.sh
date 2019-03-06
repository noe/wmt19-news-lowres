#!/bin/bash

# Script to download the WMT19 news translation data for Kazakh

if [[ "$OSTYPE" == "darwin"* ]]; then
  alias sed=gsed
fi

news_commentary(){
  BASE_URL='http://data.statmt.org/news-commentary/v14/training/'
  KAZAKH_FILES=$(curl -s $BASE_URL | grep --color=never kk | sed 's,.*href="\(.*\)">n.*,\1,g')
  for i in $KAZAKH_FILES; do
     wget $BASE_URL/$i
  done
}

wikititles(){
  wget 'http://data.statmt.org/wikititles/v1/wikititles-v1.kk-en.tsv.gz'
}

nazarbayev_uni(){
  # An English-Kazakh crawled corpus of about 100k sentences, prepared
  # by Bagdat Myrzakhmetov of Nazarbayev University. The corpus is distributed
  # as a tsv file with the original URLs included, as well as an alignment score.
  wget 'http://data.statmt.org/wmt19/translation-task/kazakhtv.kk-en.tsv.gz'

  # A crawled Russian-Kazakh corpus of about 5M sentences, also prepared
  # by Bagdat Myrzakhmetov.
  wget 'http://data.statmt.org/wmt19/translation-task/crawl.kk-ru.gz'
}


news_commentary
wikititles
nazarbayev_uni

for i in *.gz; do gunzip $i; done

mv crawl.kk-ru crawl.kk-ru.tsv


# Remove the files that overlap with the development data.
# See this message to the WMT group to know more:
# https://groups.google.com/forum/#!searchin/wmt-tasks/kazakh|sort:date/wmt-tasks/5-uzVfMRNR0/t35358ArBgAJ
rm news-commentary-v14.en-kk.tsv

