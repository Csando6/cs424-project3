import tokenize
import re
import pandas as pd
from numpy.compat import unicode

filepath = "workFiles/certificates.list"
#filepath = "certificates-copy.list"


#counter = 1000
matrix = []
with open(filepath, 'r') as file:
    #itterate through file
    for line in file:
        if re.match("[\w\s]+\(.+\)\s+\w+\:.+\(.+\)",line):
            line = line.replace("\t","")
            line = line.replace("\n","")
            lineS = re.split("\(|\)|\:",line)
            [elem.replace(" ","") for elem in lineS[1:]]
            if lineS[-1] == "":del(lineS[-1])
            if(len(lineS) == 5):
                matrix.append(lineS)

customHeader = ["name","year","country","rating","certificate"]
dataframe = pd.DataFrame.from_records(matrix,columns=customHeader)

dataframe.to_csv(filepath[:-5]+"-cleaned.csv", index=False)
print("csv generated.")
        