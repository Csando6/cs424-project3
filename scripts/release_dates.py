import re
import pandas as pd
from numpy.compat import unicode

print('scripting release-dates.py')
filepath = "../workFiles/release-dates.list"

removables = ['(TV)', '(V)', '(VG)', '(internet)', 'blu-ray premiere', 're-release', '????']    #items to remove
count_rem_quote = 0  #init counters to 0
count_rem_brute = 0
count_rem_not2 = 0
count_good = 0

matrix = []
with open(filepath, 'r') as file:
    
    #iterate through file
    for line in file:

        #discard lines that start with double quote
        if(line[0]=="\""):
            count_rem_quote += 1
            pass  #do nothing
        
        #discard lines with item from removables list:
        elif any(rem in line for rem in removables):
            count_rem_brute += 1
            pass  #do nothing
       
        #not in removables:
        else:

            #seperate the line by tabs (into 2 or 3 sections)
            #ex: ['101 Dalmatians (1996)', 'Portugal:10 March 1997', '(premiere)\n']
            sections = re.split('\t+', line)

            try:
                #prepare section 0
                section0 = sections[0]
                if(section0[-1] == ')'):       #remove last parenthasis
                    section0 = section0[:-1]
                section0_split = re.split('\)\s\(|\s\(|\)\s', section0) #split on parenthesis
                #print(section0_split)
                
                #prepare section 1
                section1 = sections[1]
                if(section1[-1] == '\n'):       #remove newline
                    section1 = section1[:-1]
                section1_split = re.split(':', section1)


                #discard lines that don't have 2 attributes in section 0
                if (len(section0_split) != 2):
                    count_rem_not2 += 1
                    pass  #do nothing
                    
                #keep good lines. split them up in a list: 
                else:
                    try:   #if there is a section2:
                        #prepare section 2
                        section2 = sections[2][:-1]
                        section2 = re.sub('\)\s\(', '; ', section2) #replace ( ) with ; 
                        section2 = re.sub('\(|\)','', section2)

                        #concat
                        sLine = section0_split + section1_split + [section2]
                    except:
                        sLine = section0_split + section1_split
                
                    count_good += 1
                    matrix.append(sLine)

            except IndexError:
                pass
            

printReport = False
if(printReport):
    #summary:
    print('items removed due to " : ' + str(count_rem_quote))
    print('items removed due to bad attribute (ex: TV): ' + str(count_rem_brute))
    print('items removed due to more than 2 attributes before tabs: ' + str(count_rem_not2))
    print('items kept: ' + str(count_good))

    #print first 10 in matrix:
    print('\nmatrix sample:')
    j = 0
    for i in matrix:
        print(i)
        j += 1
        if(j > 10):break
            

customHeader = ["title","year_produced","country","date_released", "details"]
dataframe = pd.DataFrame.from_records(matrix,columns=customHeader)

dataframe.to_csv("../csvFiles/" + filepath.split('/')[2][:-5] + "-cleaned.csv", index=False)
print("csv generated.")
