import tokenize
import re
import pandas as pd
from numpy.compat import unicode

print('scripting keywords.py')

def removeWhite(line):
    i=0
    while i < len(line)-2:
        if(line[i]==' ' and line[i+1]==' ' and line[i+2]==' '):
            #  ### -> ##
            #  123 -> 13
            line = line[:i] + line[i+1:]
        else:
            i+=1
    return line

filepath = "../workFiles/keywords.list"

bad_types = ['(TV)', '(V)', '(VG)', '(internet)', 'blu-ray premiere', 're-release', '????']    #items to remove
good_keywords = set()

#init counters to 0
count_quote     = 0  
count_bad_type  = 0
count_rare_keyword = 0
movies_good      = 0
keys_good      = 0
count_total     = 0

matrixKeys = []
matrixMovies = []

with open(filepath, 'r') as file:
    #itterate through file
    for line in file:
        count_total += 1 #count lines

        #discard lines that start with double quote
        if(line[0]=="\""):
            count_quote += 1
            pass  #do nothing
        
        #discard lines with item from bad_types list:
        elif any(rem in line for rem in bad_types):
            count_bad_type += 1
            pass  #do nothing

        else:
            #keyword occurences   
            if re.match("^([\t\s]+[\w\$\-]+\s+\(\d+\)\s*)*$",line):
                line = line.replace(" ","")
                line = line.replace("\t","")
                line = line.replace("\n","")
                lineS = re.split("([\w\$\-]+\s*\(\d+\))",line)

                for elem in lineS:
                    elemS = re.split("\(|\)",elem)
                    if(len(elemS)==3 and elemS[2]==''):
                        del(elemS[2])
                        
                    if(len(elemS) == 2):
                        
                        #add 20+ occurences keywords to set
                        if(int(elemS[1]) >= 20):
                            count_rare_keyword += 1
                            good_keywords.add(elemS[0])
                        
                        keys_good += 1
                        matrixKeys.append(elemS)

            #movies
            elif re.match("[\w\s\'\"\:\-]+\(\d{4}\)\s+[\w\-]+",line):
                line = line.replace("\t"," ")
                line = line.replace("\n","")
                line = removeWhite(line)
                lineS = re.split("\(|\)|\s\s",line)
                if(len(lineS)==4 and lineS[2]==''):
                    del(lineS[2])
                
                if(len(lineS)==3 and lineS[2] in good_keywords):
                    movies_good += 1
                    movieID = lineS[0][:-1] + '-' + lineS[1]
                    matrixMovies.append([movieID] + lineS)

printReport = True
if(printReport):

    #report:
    print('...')
    print('items total: ' + str(count_total))
    print('items removed due to " : ' + str(count_quote))
    print('items removed due to bad type (ex: TV): ' + str(count_bad_type))
    print('items removed due to being from a rare (<20) keyword: ' + str(count_rare_keyword))
    print('movies kept: ' + str(movies_good))
    print('keys kept: ' + str(keys_good))
    print('...')

                
root = filepath.split('/')[2][:-5]
            
#creating file for keywords
headerKeys = ["keyword","rating"]
dataKeys = pd.DataFrame.from_records(matrixKeys,columns=headerKeys)
dataKeys.to_csv("../csvFiles/" + root +"-keys-cleaned.csv", index=False)
print(root + " keys csv generated.")

#creating file for movies
dataMovie = pd.DataFrame.from_records(matrixMovies)
dataMovie.to_csv("../csvFiles/" + root +"-movies-cleaned.csv", sep='\t', header=False, index=False)
print(root + " movies csv generated.")