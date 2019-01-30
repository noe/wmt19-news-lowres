#!/bin/bash

#. `dirname $0`/../common/vars

moses_scripts=/home/usuaris/veu4/usuaris31/moses/mosesdecoder/scripts/
rapid_dir=../data/en-et/rapid/
pc_dir=../data/en-et/paracrawl/
ep_et_dir=../data/en-et/europarl-v8/
dev_dir=../data/dev/
max_len=50

src=et
tgt=en
pair=$src-$tgt
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
tok $pc_dir/paracrawl PARACRAWL
tok $rapid_dir/rapid2016.$tgt-$src RAPID 
tok $ep_et_dir/europarl-v8.$pair EUROPARL
#
#
#
##
####
#### Clean
`dirname $0`/../scripts/clean-corpus-n.perl corpus.tok $src $tgt corpus.clean 1 $max_len corpus.retained
####
##
#### Train truecaser and truecase
for lang in $src $tgt; do
  $moses_scripts/recaser/train-truecaser.perl -model truecase-model.$lang -corpus corpus.tok.$lang
  $moses_scripts/recaser/truecase.perl < corpus.clean.$lang > corpus.tc.$lang -model truecase-model.$lang
done
##
  
# dev sets
for devset in dev2018 ; do
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
tar zcvf dev.tgz news* &&  rm news*
tar zcvf true.tgz truecase-model.* && rm truecase-model*
