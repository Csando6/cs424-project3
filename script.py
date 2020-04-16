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
filterList = ["VG"]
matrix = []

with open(filepath, 'r') as file:
    #itterate through file
    for line in file:
        if(line[0]=="'" or line[0]=="\""):
            #do nothing
            line
        elif re.match(".+\(\d+\)\s+\(.+\)\s*[\w\s]+:.+", line):
            line = line.replace('\t','')
            line = line.replace('\n','')
            lineS = re.split("\(|\)|\:[.]*",line)
            del lineS[2]
            #print(lineS)
            if(len(lineS) == 5 and not any(elem in lineS[2] for elem in filterList) ):
                matrix.append(lineS)
            
    
customHeader = ["name","year","rating","country","date"]
dataframe = pd.DataFrame.from_records(matrix,columns=customHeader)

dataframe.to_csv(filepath[:-5]+"-cleaned.csv", index=False)
print("csv generated.")

