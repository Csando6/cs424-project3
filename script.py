import tokenize
import re
import pandas as pd
from numpy.compat import unicode

#if your file is in the same directory:
#filename = 'release-dates.list'
#file = open(filename)

#if your file is within LIST_files
#filepath = path.relpath("release-dates copy.list")
#filepath = "release-dates copy.list"
filepath = "workFiles/release-dates.list"

#counter = 1000
matrix = []
with open(filepath, 'r') as file:
    #itterate through file
    for line in file:
        #line = unicode(line, errors="ignore")
        #print(line)
        #regex expression to split line
        line = line.replace('\t',' ')
        line = line.replace('\n','')
        #line = line.replace('  ',' ')
        #print(line)
        sLine = re.split("\s\(|\)\s|\{|\}|\:[1-40]",line)

        #filters out movie name with "name"
        if sLine and sLine[0].find("\""):
            if len(sLine)== 5:
                for i in range(len(sLine)):
                    sLine[i] = sLine[i].replace("(","");
                matrix.append(sLine);
            else:
                #debug 
                #TODO:later give some conditions to add other lines into the code
                print(sLine)
            #counter -= 1
        #if(counter < 0):
        #    break
    
customHeader = ["name","year","rating","country","date"]
dataframe = pd.DataFrame.from_records(matrix,columns=customHeader)

dataframe.to_csv(filepath[0:10]+"-cleaned.csv", index=False)
print("csv generated.")
#for elem in exmatrix:
#    print(elem)

