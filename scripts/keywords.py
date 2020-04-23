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

#filepath = "../workFiles/keywords-copy.list"
filepath = "../workFiles/keywords.list"


matrixKeys = []
headerKeys = ["keyword","rating"]
matrixMovies = []
headerMovies = ["name","year","keyword"]
#counter = 0
with open(filepath, 'r') as file:
    #itterate through file
    for line in file:
        #counter +=1
        #if((counter%1000000)== 0):#million
        #    print(str(counter)+": "+line)
        if re.match("^([\t\s]+[\w\$\-]+\s+\(\d+\)\s*)*$",line):
            line = line.replace(" ","")
            line = line.replace("\t","")
            line = line.replace("\n","")
            lineS = re.split("([\w\$\-]+\s*\(\d+\))",line)
            #lineS = filter(None,lineS)
            #print(lineS)
            for elem in lineS:
                elemS = re.split("\(|\)",elem)
                if(len(elemS)==3 and elemS[2]==''):
                    del(elemS[2])
                #print(elemS)
                if(len(elemS) == 2):
                    matrixKeys.append(elemS)

        elif re.match("[\w\s\'\"\:\-]+\(\d{4}\)\s+[\w\-]+",line):
            line = line.replace("\t"," ")
            line = line.replace("\n","")
            line = removeWhite(line)
            lineS = re.split("\(|\)|\s\s",line)
            if(len(lineS)==4 and lineS[2]==''):
                del(lineS[2])
            #     del(lineS[4])
            #print(lineS)
            #lineS = filter(None, lineS)
            if(len(lineS)==3):
                matrixMovies.append(lineS)
            
#creating file for keywords
dataKeys = pd.DataFrame.from_records(matrixKeys,columns=headerKeys)
dataKeys.to_csv(filepath[:-5]+"-keys-cleaned.csv", index=False)


#creating file for movies
dataMovie = pd.DataFrame.from_records(matrixMovies,columns=headerMovies)
dataMovie.to_csv(filepath[:-5]+"-movies-cleaned.csv", index=False)

print("csv generated.")
