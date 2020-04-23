import re
import pandas as pd
import codecs
from numpy.compat import unicode

print('scripting genres.py')
filepath = "../workFiles/genres.list"

bad_types = ['(TV)', '(V)', '(VG)', '(internet)', 'blu-ray premiere', 're-release', '????']    #items to remove
bad_genres = ['Short', 'Adult', 'Reality-TV',  'Talk-Show', 'Game-Show', 'News', 'Reality-tv', 'Sci-fi', 'Sex',
              'Lifestyle', 'Hardcore', 'Experimental', 'Erotica', 'Commercial']
bad_genre_movies = set()

#init counters to 0
count_quote     = 0  
count_bad_type  = 0
count_not_2     = 0
count_bad_genre = 0
count_good      = 0
count_total     = 0

matrix = []

#with codecs.open(filepath, 'r', 'iso-8859-1') as file:  #trying decoding
with open(filepath, 'r') as file:
    
    #iterate through file
    for line in file:
        count_total += 1 #count lines
        
        #print(line) #trying decoding
        #line = line.encode('iso-8859-1').decode('utf-8')
        #print(line)
        
        #discard lines that start with double quote
        if(line[0]=="\""):
            count_quote += 1
            pass  #do nothing
        
        #discard lines with item from bad_types list:
        elif any(rem in line for rem in bad_types):
            count_bad_type += 1
            pass  #do nothing
       
        else:
            #seperate the line by tabs      ex: ['#30 (2015)', 'Drama\n']
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
                    
                #keep good lines (some bad genre movies remain but will be removed later)
                else:
                    section1 = sections[1]       #prepare section 1 (genre)
                    if(section1[-1] == '\n'):
                        section1 = section1[:-1]

                    #if a bad genre: put into bad set                            
                    if (section1 in bad_genres):
                        count_bad_genre += 1
                        bad_genre_movies.add(movieID)

                    sLine = [movieID] + section0_split + [section1] #concat
                    count_good += 1
                    matrix.append(sLine)

            except IndexError:
                pass
            

#write bad-genre movies into text file
f = open('../csvFiles/bad_movie_list.txt', 'a')
for movie in bad_genre_movies:
    f.write(movie + '\n')
f.write('----------\n')
print("txt updated with bad genre movies.")
f.close()


printReport = True
if(printReport):

    #report:
    print('...')
    print('items total: ' + str(count_total))
    print('items removed due to " : ' + str(count_quote))
    print('items removed due to bad type (ex: TV): ' + str(count_bad_type))
    print('items removed due to not 2 attributes before tabs: ' + str(count_not_2))
    print('items marked as bad_genre : ' + str(count_bad_genre))
    print('items kept: ' + str(count_good))
    print('...')


#2D list -> dataframe
dataframe = pd.DataFrame.from_records(matrix) 

#dataframe -> csv
root = filepath.split('/')[2][:-5]
dataframe.to_csv("../csvFiles/" + root + "-cleaned.csv", sep='\t', header=False, index=False)
print(root + " csv generated.")
print('...')
