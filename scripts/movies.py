import re
import pandas as pd
from numpy.compat import unicode

print('scripting movies.py')
filepath = "../workFiles/movies-short.list"

bad_types = ['(TV)', '(V)', '(VG)', '(internet)', 'blu-ray premiere', 're-release', '????']    #items to remove

#init counters to 0
count_quote     = 0  
count_bad_type  = 0
count_not_2     = 0
count_good      = 0
count_total     = 0

matrix = []

with open(filepath, 'r') as file:
    
    #iterate through file
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

            #seperate the line by tabs     #ex: ['Prince Edward Island (1943)', '1943\n']
            sections = re.split('\t+', line)

            try:
                #prepare section 0
                section0 = sections[0]
                if(section0[-1] == ')'):       #remove last parenthesis
                    section0 = section0[:-1]
                section0_split = re.split('\)\s\(|\s\(|\)\s', section0) #split on parenthesis
                movieID = section0_split[0] + '-' + section0_split[1]   #define a unique movieID by combining title and year


                #discard lines that don't have 2 attributes in section 0
                if (len(section0_split) != 2):
                    count_not_2 += 1
                    pass  #do nothing
                    
                #keep good lines 
                else:
                    section1 = sections[1]         #prepare section 1 (year2)
                    if(section1[-1] == '\n'):
                        section1 = section1[:-1]
                    
                    sLine = [movieID] + section0_split + [section1] #concat
                    count_good += 1
                    matrix.append(sLine)

            except IndexError:
                pass
            

printReport = False
if(printReport):

    #report:
    print('...')
    print('items total: ' + str(count_total))
    print('items removed due to " : ' + str(count_quote))
    print('items removed due to bad type (ex: TV): ' + str(count_bad_type))
    print('items removed due to not 2 attributes before tabs: ' + str(count_not_2))
    print('items kept: ' + str(count_good))
    print('...')


#2D list -> dataframe
dataframe = pd.DataFrame.from_records(matrix) 

#dataframe -> csv
root = filepath.split('/')[2][:-5]
dataframe.to_csv("../csvFiles/" + root + "-cleaned.csv", sep='\t', header=False, index=False)
print(root + " csv generated.")
