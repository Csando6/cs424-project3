import re
import pandas as pd
import codecs
from numpy.compat import unicode

print('scripting certificates.py')
filepath = "../workFiles/certificates.list"

bad_types = ['(TV)', '(V)', '(VG)', '(internet)', 'blu-ray premiere', 're-release', '????']    #items to remove
rem_certificates = [':TV-G', ':TV-14', ':TV-Y', ':TV-PG', ':TV-MA', 'TV rating', 'tv rating',
                    ':E', ':E10+', ':T', ':C', ':M', 'Not Rated', 'not rated', ':unrated', ':Unrated']
bad_certificates = ['USA:X', 'USA:NC-17']
bad_certificate_movies = set()

#init counters to 0
count_quote     = 0  
count_bad_type  = 0
count_not_2     = 0
count_rem_cert  = 0
count_bad_cert  = 0
count_rem_country = 0
count_good      = 0
count_total     = 0

matrix = []

with open(filepath, 'r') as file:

    #itterate through file
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

        #discard line with item from rem_certificates list:
        elif any(rem in line for rem in rem_certificates):
            count_rem_cert += 1
            pass  #do nothing

        else:
            #seperate the line by tabs      ex: ["'71 (2014)", 'South Korea:15', '(2016)\n']
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
                    
                #keep good lines (some bad certificate movies remain but will be removed later)
                else:
                    #prepare section 1 (country:cert)
                    section1 = sections[1]
                    if(section1[-1] == '\n'):       #remove newline
                        section1 = section1[:-1]

                    #if a bad certificate: put into bad set    
                    if (section1 in bad_certificates):
                        count_bad_cert += 1
                        bad_certificate_movies.add(movieID)

                    section1_split = re.split(':', section1)

                    #discard items with a different country than USA
                    if section1_split[0] != 'USA':
                        count_rem_country += 1
                        pass   #do nothing

                    else:
                    
                        try:   #if there is a section2:
                            #prepare section 2
                            section2 = sections[2][:-1]
                            section2 = re.sub('\)\s\(', '; ', section2) #replace ) ( with ; 
                            section2 = re.sub('\(|\)','', section2)

                            #concat
                            sLine = [movieID] + section0_split + section1_split + [section2]

                        except: #section2 doesn't exist:
                            sLine = [movieID] + section0_split + section1_split

                        count_good += 1
                        matrix.append(sLine)

                    
            except IndexError:
                pass


#write bad-certificate movies into text file
f = open('../csvFiles/bad_movie_list.txt', 'a')
for movie in bad_certificate_movies:
    f.write(movie + '\n')
f.write('----------\n')
print("txt updated with bad certificate movies.")
f.close()



printReport = True
if(printReport):

    #report:
    print('...')
    print('items total: ' + str(count_total))
    print('items removed due to " : ' + str(count_quote))
    print('items removed due to bad type (ex: TV): ' + str(count_bad_type))
    print('items removed due to bad (rem) certificate (ex: Not Rated): ' + str(count_rem_cert))
    print('items removed due to not 2 attributes before tabs: ' + str(count_not_2))
    print('items removed due to having a non-USA certificate: ' + str(count_rem_country))
    print('items marked as bad_certificate : ' + str(count_bad_cert))
    print('items kept: ' + str(count_good))
    print('...')


#2D list -> dataframe
dataframe = pd.DataFrame.from_records(matrix) 

#datafram -> csv
root = filepath.split('/')[2][:-5]
dataframe.to_csv("../csvFiles/" + root + "-cleaned.csv", sep='\t', header=False, index=False)
print(root + " csv generated.")
print('...')
        



