#!/usr/bin/env python3

import argparse
import string
import sys


NUMBER_OR_PUNCTUATION = string.punctuation + " 0123456789"


def is_sentence_ok(sentence, max_ratio):
    length = len(sentence)
    ratio = sum(1. if c in NUMBER_OR_PUNCTUATION else 0. for c in sentence) / length
    return ratio < max_ratio


def filter_lines(max_numeric_ratio, is_tsv):
    separator = "\t" if is_tsv else ""
    for line in sys.stdin:
        line = line.strip('\r\n ')
        sentences = line.split(separator)[:2] if is_tsv else [line]
        is_ok = all(is_sentence_ok(s, max_numeric_ratio) for s in sentences)
        if not is_ok:
            continue
        print("{}{}{}".format(sentences[0],separator, sentences[1] if is_tsv else ""))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--max-ratio', type=float, required=True)
    parser.add_argument('--tsv', action='store_true')
    args = parser.parse_args()
    filter_lines(args.max_ratio, args.tsv)


if __name__ == '__main__':
    main()
