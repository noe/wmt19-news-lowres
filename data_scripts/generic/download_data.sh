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

news_commentary_ruen(){
  wget 'http://data.statmt.org/news-commentary/v14/training/news-commentary-v14.en-ru.tsv.gz'
}


wikititles(){
  wget 'http://data.statmt.org/wikititles/v1/wikititles-v1.kk-en.tsv.gz'
}

wikititles_ruen(){
  wget 'http://data.statmt.org/wikititles/v1/wikititles-v1.ru-en.tsv.gz'
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


commoncrawl(){
  wget 'http://www.statmt.org/wmt13/training-parallel-commoncrawl.tgz'
}

paracrawl(){
  wget 'https://s3.amazonaws.com/web-language-models/paracrawl/release1/paracrawl-release1.en-ru.zipporah0-dedup-clean.tgz'
}

yandex_corpus(){
  #Download link expires on 09/03/2019.
  wget 'https://translate.yandex.net/corpus/1mcorpus.zip?st=bjSS7KI_WN7235LdmPjvtA&e=1552140741&ui=ru'
  mv '1mcorpus.zip?st=bjSS7KI_WN7235LdmPjvtA&e=1552140741&ui=ru' 1mcorpus.zip

}

un_corpus(){
 #Cookies may expire
 wget --load-cookies cookies.txt https://cms.unov.org/UNCorpus/en/Download?file=UNv1.0.en-ru.tar.gz.00
 wget --load-cookies cookies.txt https://cms.unov.org/UNCorpus/en/Download?file=UNv1.0.en-ru.tar.gz.01
 wget --load-cookies cookies.txt https://cms.unov.org/UNCorpus/en/Download?file=UNv1.0.en-ru.tar.gz.02 
 cat 'Download?file=UNv1.0.en-ru.tar.gz.00' 'Download?file=UNv1.0.en-ru.tar.gz.01' 'Download?file=UNv1.0.en-ru.tar.gz.02' > un.en-ru.tar.gz
 more 'Download?file=UNv1.0.en-ru.tar.gz.00' 'Download?file=UNv1.0.en-ru.tar.gz.01' 'Download?file=UNv1.0.en-ru.tar.gz.02'
}


download_training_data(){
  news_commentary
  wikititles
  nazarbayev_uni
  for i in *.gz; do gunzip $i; done
  mv crawl.kk-ru crawl.kk-ru.tsv
  # Remove the files that overlap with the development data.
  # See this message to the WMT group to know more:
  # https://groups.google.com/forum/#!searchin/wmt-tasks/kazakh|sort:date/wmt-tasks/5-uzVfMRNR0/t35358ArBgAJ
  rm news-commentary-v14.en-kk.tsv

  #Download ru-en data in a subfolder
  mkdir -p ru-en 
  cd ru-en
  
  news_commentary_ruen
  wikititles_ruen
  commoncrawl
  paracrawl
  yandex_corpus
  un_corpus
  
  for i in *.gz; do gunzip $i; done
  for i in *.tgz; do tar -xvzf $i; done
  for i in *.zip; do unzip $i; done

  cd ..
}


download_dev_data(){
  wget http://data.statmt.org/wmt19/translation-task/dev.tgz
  tar xzvf dev.tgz
  mv dev/* .
  rm dev/.history-bhaddow
  rmdir dev
}

mkdir -p train
cd train
download_training_data
cd ..

mkdir -p dev
cd dev
download_dev_data
cd ..


