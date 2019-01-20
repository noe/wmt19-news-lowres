#!/bin/bash

reverse_all(){
  # reverse kk-en to en-kk
  for FILE in *.kk-*; do
    REVERSED=$(echo $FILE | sed 's,\(.*\)\.kk-\(..\)\.\(.*\),\1.\2-kk.\3,g')
    echo "Reversing $FILE to $REVERSED..."
    sed 's,\(.*\)\t\(.*\),\2\t\1,g' $FILE > $REVERSED
  done
}

reverse_all
