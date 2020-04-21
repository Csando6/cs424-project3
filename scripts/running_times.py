import re
import pandas as pd
from numpy.compat import unicode

print('scripting running_times.py')
filepath = "../workFiles/running-times-short.list"

bad_types = ['(TV)', '(V)', '(VG)', '(internet)', 'blu-ray premiere', 're-release', '????']    #items to remove
bad_duration_movies = set()
good_set = set()

#init counters to 0
count_quote     = 0  
count_bad_type  = 0
count_runtime_format = 0
count_not_2     = 0
count_bad_dur_entry = 0
count_bad_duration  = 0
count_good      = 0
count_good_2    = 0
count_total     = 0

matrix  = []

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
            #seperate the line by tabs      ex: ['Calling the Shots (2010)', 'USA:18', '(approx.)\n']
            sections = re.split('\t+', line)

            try:
                #prepare section 0
                section0 = sections[0]
                if(section0[-1] == ')'):       #remove last parenthesis
                    section0 = section0[:-1]
                section0_split = re.split('\)\s\(|\s\(|\)\s', section0) #split on parenthesis
                movieID = section0_split[0] + '-' + section0_split[1]   #define a unique movieID by combining title and year
                
                #prepare section 1
                section1 = sections[1]
                if(section1[-1] == '\n'):       #remove newline
                    section1 = section1[:-1]

                if (len(re.findall(':',section1)) == 0):    #some entries don't have 'country:' -> give it at least a ':'
                    section1 = ':' + section1
                    
                section1_split = re.split(':',section1,1)


                #if duration is unconventional (around 1300 of those): just remove that entry
                split_time = re.split(':|\.|;|\'|-|,|\s|\"|m|/|x|\+|\*', section1_split[1])
                if len(split_time) > 1: #don't want a foramt that is not a single digit
                    count_runtime_format += 1
                    pass  #do nothing

                #discard lines that don't have 2 attributes in section 0
                elif (len(section0_split) != 2):
                    count_not_2 += 1
                    pass  #do nothing
                
                #keep good lines (some bad duration movies will be removed later)
                else:

                    #if 60+ duration -> add to good set
                    if(int(section1_split[1]) >= 60):
                        good_set.add(movieID)

                    else:  #don't add to good set                    
                        count_bad_dur_entry += 1

                    try:   #if there is a section2:
                        #prepare section 2
                        section2 = sections[2][:-1]
                        section2 = re.sub('\)\s\(', '; ', section2) #replace )( with ; 
                        section2 = re.sub('\(|\)','', section2)
                        
                        sLine = [movieID] + section0_split + section1_split + [section2]  #concat

                    except: #section 2 doesn't exist
                        sLine = [movieID] + section0_split + section1_split

                    #add result to matrix 1
                    count_good += 1
                    matrix.append(sLine)
                        
            except IndexError:
                pass

#now that we have matrix 1 -> remove bad entries from it. good entries go to matrix 2.
matrix2 = []
for movie in matrix:
    if movie[0] not in good_set: #not good -> bad
        count_bad_duration += 1
        bad_duration_movies.add(movie[0])
    if int(movie[4]) >= 60:  #append only movies 60+
        count_good_2 += 1
        matrix2.append(movie)


#write bad-duration movies into text file
f = open('../csvFiles/bad_movie_list.txt', 'a')
for movie in bad_duration_movies:
    f.write(movie + '\n')
f.write('----------\n')
print("txt updated with bad durations.")
f.close()


printReport = False
if(printReport):

    #report:
    print('...')
    print('items total: ' + str(count_total))
    print('items removed due to " : ' + str(count_quote))
    print('items removed due to bad type (ex: TV): ' + str(count_bad_type))
    print('items removed to bad runtime format : ' + str(count_runtime_format))
    print('items removed due to not 2 attributes before tabs: ' + str(count_not_2))
    print('items removed due to being a bad duration entry: ' + str(count_bad_dur_entry))
    print('items kept: ' + str(count_good))
    print('items marked as bad duration : ' + str(count_bad_duration))
    print('items kept 2: ' + str(count_good_2))
    print('...')



#2D list -> dataframe
dataframe = pd.DataFrame.from_records(matrix2) 

#datafram -> csv
root = filepath.split('/')[2][:-5]
dataframe.to_csv("../csvFiles/" + root + "-cleaned.csv", sep='\t', header=False, index=False)
print(root + " csv generated.")

            

##customHeader = ["title","year_produced","country","time_min", "details"]
##dataframe = pd.DataFrame.from_records(matrix,columns=customHeader)
##
##dataframe.to_csv("../csvFiles/" + filepath.split('/')[2][:-5] + "-cleaned.csv", index=False)
##print("csv generated.")
