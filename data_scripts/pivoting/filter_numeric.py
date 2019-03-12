#!/usr/bin/env python3

import argparse
import sys


def is_sentence_ok(sentence, max_numeric_ratio):
    ratio = sum(1. if c.isnumeric() else 0. for c in sentence) / len(sentence)
    return ratio < max_numeric_ratio


def filter_lines(max_numeric_ratio, is_tsv):
    separator = "\t" if is_tsv else ""
    for line in sys.stdin:
        line = line.strip()
        sentences = line.split(separator)[:2] if is_tsv else [line]
        is_ok = all(is_sentence_ok(s, max_numeric_ratio) for s in sentences)
        if not is_ok:
            continue
        print(sentences[0] + separator + (sentences[1] if is_tsv else ""))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--max-ratio', type=float, required=True)
    parser.add_argument('--tsv', action='store_true')
    args = parser.parse_args()
    filter_lines(args.max_ratio, args.tsv)


if __name__ == '__main__':
    main()
