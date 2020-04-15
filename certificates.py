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
        if(re.match(".+\(\d+\)\s+\(.+\)\s+\w+:.+",line) ):
            print(line)
        