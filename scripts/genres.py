import re
import pandas as pd
from numpy.compat import unicode

print('scripting genres.py')
filepath = "../workFiles/genres-short.list"

bad_types = ['(TV)', '(V)', '(VG)', '(internet)', 'blu-ray premiere', 're-release', '????']    #items to remove
bad_genres = ['Short', 'Adult', 'Reality-TV',  'Talk-Show', 'Game-Show', 'News', 'Reality-tv', 'Sci-fi', 'Sex', 'Lifestyle', 'Hardcore', 'Experimental', 'Erotica', 'Commercial']
bad_movies_due_to_genre = {''} #set

count_rem_quote = 0  #init counters to 0
count_rem_badtype = 0
count_rem_not2 = 0
count_rem_badgenre = 0
count_good = 0

matrix = []
with open(filepath, 'r') as file:
    
    #iterate through file
    for line in file:

        #discard lines that start with double quote
        if(line[0]=="\""):
            count_rem_quote += 1
            pass  #do nothing
        
        #discard lines with item from bad_types list:
        elif any(rem in line for rem in bad_types):
            count_rem_badtype += 1
            pass  #do nothing
       
        else:

            #seperate the line by tabs (into sections)
            #ex: ['#30 (2015)', 'Drama\n']
            sections = re.split('\t+', line)

            try:
                #prepare section 0
                section0 = sections[0]
                if(section0[-1] == ')'):       #remove last parenthasis
                    section0 = section0[:-1]
                section0_split = re.split('\)\s\(|\s\(|\)\s', section0) #split on parenthesis
                movieID = section0_split[0] + '-' + section0_split[1]   #define a unique movieID by combining title and year

                #discard lines that don't have 2 attributes in section 0
                if (len(section0_split) != 2):
                    count_rem_not2 += 1
                    pass  #do nothing
                    
                #keep good lines. split them up in a list: 
                else:
                    section1 = sections[1][:-1]         #prepare section 1 (genre)
                    if (section1 in bad_genres):
                        bad_movies_due_to_genre.add(movieID)

                    sLine = [movieID] + section0_split + [section1] #concat
                    count_good += 1
                    matrix.append(sLine)

            except IndexError:
                pass


print(bad_movies_due_to_genre)
            
for i in matrix:
    if (i[0] in bad_movies_due_to_genre):
        print(i)
        count_rem_badgenre += 1
        count_good -= 1
        matrix.remove(i)



printReport = True
if(printReport):
    #summary:
    
    print('items removed due to " : ' + str(count_rem_quote))
    print('items removed due to bad type (ex: TV): ' + str(count_rem_badtype))
    print('items removed due to not 2 attributes before tabs: ' + str(count_rem_not2))
    print('items removed due to bad genre : ' + str(count_rem_badgenre))
    print('items kept: ' + str(count_good))

    #print first 10 in matrix:
    print('\nmatrix sample:')
    j = 0
    for i in matrix:
        print(i)
        j += 1
        if(j > 10):break
            

customHeader = ["movieID", "title","year_produced","genre"]
dataframe = pd.DataFrame.from_records(matrix,columns=customHeader)

dataframe.to_csv("../csvFiles/" + filepath.split('/')[2][:-5] + "-cleaned.csv", index=False)
print("csv generated.")
