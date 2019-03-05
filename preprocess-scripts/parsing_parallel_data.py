import re



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

