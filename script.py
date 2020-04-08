import tokenize
import re
from numpy.compat import unicode

#if your file is in the same directory:
#filename = 'release-dates.list'
#file = open(filename)

#if your file is within LIST_files
#filepath = path.relpath("release-dates copy.list")
#filepath = path.relpath("release-dates.list")
filepath = "release-dates.list"

counter = 1000
matrix = []
with open(filepath, 'r') as file:
    #itterate through file
    for line in file:
        #line = unicode(line, errors="ignore")
        #print(line)
        #regex expression to split line
        line = line.replace('\t','')
        line = line.replace('\n','')
        sLine = re.split('\(|\)|\{|\}|:\d|\n',line)

        #filters out movie name with "name"
        if sLine and sLine[0].find("\"") and sLine[0].find("#"):
            matrix.append(sLine);
            #print(sLine)
            counter -= 1
        if(counter < 0):
            break
    
for elem in matrix:
    print(elem)

