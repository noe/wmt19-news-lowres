#!/bin/bash

#. `dirname $0`/../common/vars

moses_scripts=/home/usuaris/veu4/usuaris31/moses/mosesdecoder/scripts/
kazakhtv_dir=../data/kazakhtv/
news_dir=../data/news/
#wikititles_dir=../data/wikititles/
dev_dir=../data/dev/
max_len=50

src=kk
tgt=en
pair=$src-$tgt
pair_reverse=$tgt-$src
#
tok() {
  path=$1
  name=$2
  for lang in $src $tgt; do
    $moses_scripts/tokenizer/normalize-punctuation.perl -l $lang < $path.$lang | \
    $moses_scripts/tokenizer/tokenizer.perl -no-escape -a -l $lang  \
    >> corpus.tok.$lang
  done
  lines=`wc -l $path.$src | cut -d' ' -f 1`
  echo $name $lines
  yes $name | head -n $lines >> corpus.tok.domain
}
#
rm -f corpus.tok.*
#
# extract paracrawl
#for lang in $src $tgt; do
#  tar  xzvOf  $pc_dir/paracrawl-release1.$tgt-$src.zipporah0-dedup-clean.tgz\
#       paracrawl-release1.$tgt-$src.zipporah0-dedup-clean.$lang > paracrawl.$lang
#done
#
# Tokenise
tok $kazakhtv_dir/kazakhtv.$pair KAZAKHTV
tok $news_dir/news-commentary-v14-wmt19.$pair_reverse NEWS 
#tok $wikititles_dir/wikititles-v1.$pair WIKITITLES
#
#
#
##
####
#### Clean
 $moses_scripts/training/clean-corpus-n.perl corpus.tok $src $tgt corpus.clean 1 $max_len corpus.retained

####
##
#### Train truecaser and truecase
for lang in $src $tgt; do
  $moses_scripts/recaser/train-truecaser.perl -model truecase-model.$lang -corpus corpus.tok.$lang
  $moses_scripts/recaser/truecase.perl < corpus.clean.$lang > corpus.tc.$lang -model truecase-model.$lang
done
##
  
# dev sets
for devset in dev2019 ; do
 echo $devset
 echo $dev2018 
 for lang  in $src $tgt; do
     side="ref"
     if [ $lang = $tgt ]; then
       side="src"
     fi
     $moses_scripts/ems/support/input-from-sgm.perl < $dev_dir/news$devset-$tgt$src-$side.$lang.sgm | \
     $moses_scripts/tokenizer/normalize-punctuation.perl -l $lang | \
     $moses_scripts/tokenizer/tokenizer.perl -no-escape  -a -l $lang |  \
    $moses_scripts/recaser/truecase.perl   -model truecase-model.$lang \
     > news$devset.tc.$lang
    
  done
  cp $dev_dir/news$devset-$src$tgt*sgm .
  cp $dev_dir/news$devset-$tgt$src*sgm .
done


## Tidy up and compress
paste corpus.tc.$src corpus.tc.$tgt corpus.clean.domain | gzip -c > corpus.gz
#for lang in $src $tgt; do
#  rm -f corpus.tc.$lang corpus.tok.$lang corpus.clean.$lang corpus.retained paracrawl.$lang
#done
#rm corpus.clean.domain corpus.tok.domain
#remove comment sign for dev
#tar zcvf dev.tgz news* &&  rm news*
tar zcvf true.tgz truecase-model.* && rm truecase-model*
