import re

#split line by line and replace the tokens in the lines
def read_file_line_by_line_with_special_handling(file, file_es, file_en_coref, file_en):
    file_es = open(file_es, 'w')
    file_en = open(file_en, 'w')
    file_en_coref  = open(file_en_coref, 'w')
    with open(file) as f:
        for line in f:

            lan=line.split('\t')
            print (lan [0])
            file_es.write(lan[0]+'\n')
            print(lan[1])
            file_en_coref.write(lan[1]+'\n')
            #replace a regex of the coref
            print(re.sub("<b_crf>.*?<e_crf> ", "", lan[1]))
            en_line = re.sub("<b_crf>.*?<e_crf> ", "", lan[1])
            file_en.write(en_line+'\n')

            print ('**')


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
                file_src.write(lan[0])
            else:
                file_src.write(lan[0] + '\n')

            if '\n' in lan[1]:
                file_trg.write(lan[1])
            else :
                file_trg.write(lan[1]+ '\n')
            print ('**')





read_file_line_by_line('news-commentary-v14-wmt19.en-kk.tsv', 'news-commentary-v14-wmt19.en-kk.en', 'news-commentary-v14-wmt19.en-kk.kk')

