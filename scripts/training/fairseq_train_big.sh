#!/bin/bash

source activate nlp_pytorch

BIN_DATA_DIR=${1:?"First argument is the binary data directory"}
MODEL_DIR=${2:?"Second argument is the model directory"}


# This file is based on fairseq's translation example:
# https://github.com/pytorch/fairseq/blob/b87c536651649ad71dd8766a409ef1c032b55afa/examples/translation/README.md
# (we used a version with the Transformer examples,
#  before the Dynamic Convolutions took over the examples)

ARCH=transformer_vaswani_wmt_en_de_big 

# Train the model
mkdir -p $MODEL_DIR
fairseq-train $BIN_DATA_DIR \
  --arch $ARCH \
  --optimizer adam \
  --adam-betas '(0.9, 0.98)' \
  --clip-norm 0.0 \
  --lr-scheduler inverse_sqrt \
  --warmup-init-lr 1e-07 \
  --warmup-updates 4000 \
  --lr 0.0005 \
  --min-lr 1e-09 \
  --dropout 0.3 \
  --weight-decay 0.0 \
  --criterion label_smoothed_cross_entropy \
  --label-smoothing 0.1 \
  --max-tokens 3584 \
  --fp16
  --save-dir $MODEL_DIR

