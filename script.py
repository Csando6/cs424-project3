from os import path
import tokenize
import re

#if your file is in the same directory:
#filename = 'release-dates.list'
#file = open(filename)

#if your file is within LIST_files
filepath = path.relpath("release-dates copy.list")
with open(filepath) as file:

    #get first few lines to start out:
    i = 0
    while i < 43:
        line = file.readline()
        sLine = re.split('\(|\)|\{|\}|:|\n',line)[:-1]
        for j in range(len(sLine)):
            sLine[j] = sLine[j].replace('\t','')
        print(sLine)
        i += 1

