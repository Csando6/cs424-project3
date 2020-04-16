import re
import pandas as pd

print('scripting release-dates.py')
filepath = "release-dates.list"

removables = ['(TV)', '(V)', '(VG)', '(internet)', 'blu-ray premiere', 're-release', '????']
count_rem_brute = 0
count_rem_not2 = 0
count_good = 0

matrix = []
with open(filepath, 'r') as file:
    
    #iterate through file
    for line in file:

        #Step 1: Brutely discard lines with item from removables list:
        if any(rem in line for rem in removables):
            count_rem_brute += 1
                
        #not in removables:
        else:
            #Step 2: Discard lines that have more than 2 items in section0:
            
            sections = re.split('\t+', line)   #seperate the line by tabs (into two or three sections)

            try:
                section0 = sections[0]
                
                #use Matt's hacky method. 'F@F_code' is a unique code to replace onto.
                section0 = section0.replace(') (','F@F_code') 
                section0 = section0.replace(' (','F@F_code')
                section0 = section0.replace(') ','F@F_code')
                section0_split = section0.split('F@F_code')

                #discard lines that don't have 2 lines
                if (len(section0_split) != 2):
                    print(section0_split)
                    count_rem_not2 += 1
                    
                #Step 3: Keep good lines. split them up in a list: 
                else:
                    section1 = sections[1]
                    section1 = section1.replace(':', 'G@G_code')

                    section2 = ''
                    try:
                        section2 = ' ' + sections[2]
                    except:
                        pass

                    #paste sections back together
                    line = sections[0] + ' ' + section1 + section2
                    
                    #remove unnecessary symbols:
                    line = line.replace('\t',' ')
                    line = line.replace('  ',' ')
                    line = line.replace('  ',' ')
                    line = line.replace('  ',' ')
                    line = line.replace('  ',' ')
                    line = line.replace('  ',' ')
                    line = line.replace('  ',' ')
                    line = line.replace('  ',' ')
                    line = line.replace(')\n','')
                    line = line.replace('\n','')
                    
                    line = line.replace(') (','G@G_code')
                    line = line.replace(' (','G@G_code')
                    line = line.replace(') ','G@G_code')
                    sLine = line.split('G@G_code')

                    count_good += 1
                    matrix.append(sLine)

            except IndexError:
                pass

printReport = False
if(printReport):
    #summary:
    print('items removed due to bad attribute (ex: TV): ' + str(count_rem_brute))
    print('items removed due to more than 2 attributes before tabs: ' + str(count_rem_not2))
    print('items kept: ' + str(count_good))

    #print first 10 in matrix:
    print('\nmatrix sample:')
    j = 0
    for i in matrix:
        print(i)
        j += 1
        if(j > 10):
            break

customHeader = ["title","year_produced","country","date_released", "-", "-", "-", "-", "-"]
dataframe = pd.DataFrame.from_records(matrix,columns=customHeader)

dataframe.to_csv(filepath[:-5]+"-cleaned.csv", index=False)
print("csv generated.")
