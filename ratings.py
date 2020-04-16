import tokenize
import re
import pandas as pd
from numpy.compat import unicode

##removes whiteline <2
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

filepath = "workFiles/ratings.list"
#filepath = "ratings-copy.list"

#counter = 1000
matrix = []
with open(filepath, 'r') as file:
    #itterate through file
    for line in file:
        if re.match("\s+[\d\.]+\s+\d+\s+[\d\.]+\s+[\w\s]+\(\d+\)\s*", line):
            line = line.replace('\t','')
            line = line.replace('\n','')
            line = removeWhite(line)
            #print(line)
            lineS = re.split('\s\s|\(|\)',line)
            lineS = lineS[1:-1]
            #print(len(lineS))
            if(len(lineS) == 5):
                matrix.append(lineS)

customHeader = ["distribution","votes","rank","title","year"]
dataframe = pd.DataFrame.from_records(matrix,columns=customHeader)

dataframe.to_csv(filepath[:-5]+"-cleaned.csv", index=False)
print("csv generated.")


