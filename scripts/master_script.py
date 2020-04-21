import re
import pandas as pd
from numpy.compat import unicode

print('running master script.py')

txt_path = "../csvFiles/bad_movie_list.txt"
genres_path = "../csvFiles/genres-short-cleaned.csv"
movies_path = "../csvFiles/movies-short-cleaned.csv"
runtimes_path = "../csvFiles/running-times-short-cleaned.csv"
release_dates_path = "../csvFiles/release-dates-short-cleaned.csv"

bad_movies = set()
genres_matrix = [] #lists for the csvs
movies_matrix = []
runtimes_matrix = []  #(runtimes = running_times)
release_dates_matrix = []

#init counters to 0
count_remove_genres   = 0
count_remove_movies   = 0
count_remove_runtimes = 0
count_rem_release_dates=0

with open(txt_path) as txt, open(genres_path) as genres, \
     open(movies_path, encoding='utf-8') as movies, \
     open(runtimes_path, encoding='utf-8') as runtimes, \
     open(release_dates_path) as release_dates:
    
    #txt file
    for line in txt:
        line = line[:-1]  #take off newline
        bad_movies.add(line)

    #genres
    for line in genres:
        line = line[:-1]  #take off newline
        sLine = line.split('\t')

        #if the movie is not a bad movie: append it to the matrix
        if (sLine[0] in bad_movies):
            count_remove_genres += 1
        else:
            genres_matrix.append(sLine)


    #movies
    for line in movies:
        line = line[:-1]  #take off newline
        sLine = line.split('\t')
        
        #if the movie is not a bad movie: append it to the matrix
        if (sLine[0] in bad_movies):
            count_remove_movies += 1
        else:
            movies_matrix.append(sLine)


    #running times
    for line in runtimes:
        line = line[:-1]  #take off newline
        sLine = line.split('\t')
        
        #if the movie is not a bad movie: append it to the matrix
        if (sLine[0] in bad_movies):
            count_remove_runtimes += 1
        else:
            runtimes_matrix.append(sLine)


    #release_dates
    for line in release_dates:
        line = line[:-1]  #take off newline
        sLine = line.split('\t')
        
        #if the movie is not a bad movie: append it to the matrix
        if (sLine[0] in bad_movies):
            count_rem_release_dates += 1
        else:
            release_dates_matrix.append(sLine)

        
printReport = True
if(printReport):

    #report:
    print('genres removed from final result: ' + str(count_remove_genres))
    print('movies removed from final result: ' + str(count_remove_movies))
    print('running times removed from final result: ' + str(count_remove_runtimes))
    print('release dates removed from final result: ' + str(count_rem_release_dates))
    print('...')

#for each category:  2D List -> dataframe -> csv

#genres
genresHeader = ["movieID","title","year-produced","genre"]
genres_df = pd.DataFrame.from_records(genres_matrix,columns=genresHeader)
genres_df.to_csv("../csvFiles/final_csvFiles/" + genres_path.split('/')[2][:-4] + "-final.csv", index=False)
print("final genres csv generated.")

#movies
moviesHeader = ["movieID","title","year-produced","year"]
movies_df = pd.DataFrame.from_records(movies_matrix,columns=moviesHeader)
movies_df.to_csv("../csvFiles/final_csvFiles/" + movies_path.split('/')[2][:-4] + "-final.csv", index=False)
print("final movies csv generated.")

#running_times
runtimesHeader = ["movieID","title","year-produced","country","time-min","details"]
runtimes_df = pd.DataFrame.from_records(runtimes_matrix,columns=runtimesHeader)
runtimes_df.to_csv("../csvFiles/final_csvFiles/" + runtimes_path.split('/')[2][:-4] + "-final.csv", index=False)
print("final runtimes csv generated.")

#release_dates
releaseDatesHeader = ["movieID","title","year-produced","country","date-released", "details"]
release_dates_df = pd.DataFrame.from_records(release_dates_matrix,columns=releaseDatesHeader)
release_dates_df.to_csv("../csvFiles/final_csvFiles/" + release_dates_path.split('/')[2][:-4] + "-final.csv", index=False)
print("final release-dates csv generated.")


