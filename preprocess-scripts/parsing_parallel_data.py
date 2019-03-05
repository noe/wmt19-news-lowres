import re
import argparse


#split line by line...but before using ..check its suitability to ur file
def read_file_line_by_line(file, file_src, file_trg):
    file_src = open(file_src, 'w')
    file_trg = open(file_trg, 'w')
    with open(file) as f:
        for line in f:
            print(line)
            lan=line.split('\t')
            print(lan)
            print (lan [0])
            print(lan[1])
            if '\n' in lan[0]:
                file_src.write(lan[0].strip())
            else:
                file_src.write(lan[0].strip() + '\n')

            if '\n' in lan[1]:
                file_trg.write(lan[1].strip())
            else :
                file_trg.write(lan[1].strip()+ '\n')
            print ('**')




if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--file_to_parse", help="The name of the corpus")
    parser.add_argument("--first_parsed_file", help="The swapped corpus")
    parser.add_argument("--second_parsed_file", help="JSON of definitional pairs")
    args = parser.parse_args()

    file_to_parse = args.file_to_parse
    first_parsed_file = args.first_parsed_file
    second_parsed_file = args.second_parsed_file
    
    read_file_line_by_line(file_to_parse, first_parsed_file, second_parsed_file)

