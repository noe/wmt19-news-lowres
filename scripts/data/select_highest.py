#!/usr/bin/env python3


import argparse



def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("file1")
    parser.add_argument("scores1")
    parser.add_argument("file2")
    parser.add_argument("scores2")
    args = parser.parse_args()

    with open(args.file1) as f1, open(args.scores1) as s1, open(args.file2) as f2, open(args.scores2) as s2:
        for sent1, score1, sent2, score2 in zip(f1, s1, f2, s2):
            sent1 = sent1.strip()
            sent2 = sent2.strip()
            score1 = float(score1.strip())
            score2 = float(score2.strip())
            sent = sent1 if score1 >= score2 else sent2
            print(sent)


if __name__ == '__main__':
    main()
