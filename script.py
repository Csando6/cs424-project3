from os import path
import tokenize
import re
from numpy.compat import unicode

#if your file is in the same directory:
#filename = 'release-dates.list'
#file = open(filename)

#if your file is within LIST_files
#filepath = path.relpath("release-dates copy.list")
filepath = path.relpath("release-dates.list")


matrix = []
with open(filepath, 'r',encoding='utf-8',errors="ignore") as file:
    #itterate through file
    for line in file:
        #line = unicode(line, errors="ignore")
        #print(line)
        #regex expression to split line
        line = line.replace('\t','')
        line = line.replace('\n','')
        sLine = re.split('\(|\)|\{|\}|:|\n',line)

        #filters out movie name with "name"
        if sLine and sLine[0].find("\""):
            matrix.append(sLine);
            #print(sLine)
    
for elem in matrix:
    print(elem);

