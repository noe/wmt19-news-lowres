#!/bin/bash

# Script to download the WMT19 news translation data for Kazakh

if [[ "$OSTYPE" == "darwin"* ]]; then
  alias sed=gsed
fi

news_commentary_kk_all(){
  BASE_URL='http://data.statmt.org/news-commentary/v14/training/'
  KAZAKH_FILES=$(curl -s $BASE_URL | grep --color=never kk | sed 's,.*href="\(.*\)">n.*,\1,g')
  for i in $KAZAKH_FILES; do
     wget $BASE_URL/$i
  done
}

news_commentary_kken(){
  # See this message to the WMT group to know more:
  # https://groups.google.com/forum/#!searchin/wmt-tasks/kazakh|sort:date/wmt-tasks/5-uzVfMRNR0/t35358ArBgAJ
  wget 'http://data.statmt.org/news-commentary/v14/training/news-commentary-v14-wmt19.en-kk.tsv.gz'
}


news_commentary_kkru(){
  wget 'http://data.statmt.org/news-commentary/v14/training/news-commentary-v14.kk-ru.tsv.gz'
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
}


commoncrawl(){
  wget 'http://www.statmt.org/wmt13/training-parallel-commoncrawl.tgz'
}

paracrawl(){
  wget 'https://s3.amazonaws.com/web-language-models/paracrawl/release1/paracrawl-release1.en-ru.zipporah0-dedup-clean.tgz'
}

yandex_corpus(){
  # Downloading the Yandex corpus requires logging in, after which you are given a link
  # that is valid for 2 days. This download link expires on 11/03/2019.
  # The yandex corpus can be downloaded from https://translate.yandex.ru/corpus?lang=en
  wget 'https://translate.yandex.net/corpus/1mcorpus.zip?st=nCzaPNr7sOSr3DtWiG3buA&e=1552324310&ui=ru' -O 1mcorpus.zip
}

un_corpus_ruen(){
  # Downloading the United Nations corpus requires logging in. Here we capture
  # the cookies associated with a session in which we downloaded it
  # on 2019.03.08; cookies may expire at any time.
  # The UN corpus can be downloaded from https://cms.unov.org/UNCorpus/

  wget --header="Host: cms.unov.org" --header="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.119 Safari/537.36" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" --header="Accept-Language: es-ES,es;q=0.9,en-GB;q=0.8,en;q=0.7,zh-CN;q=0.6,zh;q=0.5,ca;q=0.4" --header="Referer: https://cms.unov.org/UNCorpus/en/DownloadOverview" --header="Cookie: NSLB=ffffffffc3a0406845525d5f4f58455e445a4a423660; __RequestVerificationToken_L1VOQ29ycHVz0=MVD3fjKngNbOobvhslYkxrg0XNhvgumtj-FO8mhBnQYvdSafRuVWF33TpobEEXx3r-GO7CjgAXl-pjsGjBCBvVlp34Y1; UserId=Noe Casas" --header="Connection: keep-alive" "https://cms.unov.org/UNCorpus/en/Download?file=UNv1.0.en-ru.tar.gz.00" -O "UNv1.0.en-ru.tar.gz.00" -c

  wget --header="Host: cms.unov.org" --header="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.119 Safari/537.36" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" --header="Accept-Language: es-ES,es;q=0.9,en-GB;q=0.8,en;q=0.7,zh-CN;q=0.6,zh;q=0.5,ca;q=0.4" --header="Referer: https://cms.unov.org/UNCorpus/en/DownloadOverview" --header="Cookie: NSLB=ffffffffc3a0406845525d5f4f58455e445a4a423660; __RequestVerificationToken_L1VOQ29ycHVz0=MVD3fjKngNbOobvhslYkxrg0XNhvgumtj-FO8mhBnQYvdSafRuVWF33TpobEEXx3r-GO7CjgAXl-pjsGjBCBvVlp34Y1; UserId=Noe Casas" --header="Connection: keep-alive" "https://cms.unov.org/UNCorpus/en/Download?file=UNv1.0.en-ru.tar.gz.01" -O "UNv1.0.en-ru.tar.gz.01" -c

  wget --header="Host: cms.unov.org" --header="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/72.0.3626.119 Safari/537.36" --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" --header="Accept-Language: es-ES,es;q=0.9,en-GB;q=0.8,en;q=0.7,zh-CN;q=0.6,zh;q=0.5,ca;q=0.4" --header="Referer: https://cms.unov.org/UNCorpus/en/DownloadOverview" --header="Cookie: NSLB=ffffffffc3a0406845525d5f4f58455e445a4a423660; __RequestVerificationToken_L1VOQ29ycHVz0=MVD3fjKngNbOobvhslYkxrg0XNhvgumtj-FO8mhBnQYvdSafRuVWF33TpobEEXx3r-GO7CjgAXl-pjsGjBCBvVlp34Y1; UserId=Noe Casas" --header="Connection: keep-alive" "https://cms.unov.org/UNCorpus/en/Download?file=UNv1.0.en-ru.tar.gz.02" -O "UNv1.0.en-ru.tar.gz.02" -c
 
 cat UNv1.0.en-ru.tar.gz.00 UNv1.0.en-ru.tar.gz.01 UNv1.0.en-ru.tar.gz.02 > un.en-ru.tar.gz
 rm UNv1.0.en-ru.tar.gz.00 UNv1.0.en-ru.tar.gz.01 UNv1.0.en-ru.tar.gz.02
}

download_ruen_data(){
  news_commentary_ruen
  wikititles_ruen
  commoncrawl
  paracrawl
  yandex_corpus
  un_corpus_ruen
  
  for i in *.tar.gz *.tgz; do tar -xvzf $i; done
  for i in *.gz; do gunzip $i; done
  for i in *.zip; do unzip $i; done
  rm training-parallel-commoncrawl.tgz paracrawl-release1.en-ru.zipporah0-dedup-clean.tgz
}

download_kkru_data(){
  # A crawled Russian-Kazakh corpus of about 5M sentences, also prepared
  # by Bagdat Myrzakhmetov.
  wget 'http://data.statmt.org/wmt19/translation-task/crawl.kk-ru.gz'
  gunzip crawl.kk-ru.gz
  mv crawl.kk-ru crawl.kk-ru.tsv

  news_commentary_kkru
}

download_kken_data(){
  news_commentary_kken
  wikititles
  nazarbayev_uni
  for i in *.gz; do gunzip $i; done
}

download_training_data(){
  mkdir -p kk-en
  cd kk-en
  download_kken_data
  cd ..

  mkdir -p ru-en 
  cd ru-en
  download_ruen_data  
  cd ..

  mkdir -p kk-ru
  cd kk-ru
  download_kkru_data
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


