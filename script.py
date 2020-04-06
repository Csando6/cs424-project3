from os import path

#if your file is in the same directory:
#filename = 'release-dates.list'
#file = open(filename)

#if your file is within LIST_files
filepath = path.relpath("LIST_files/movies.list")
file = open(filepath)

i = 0
for line in file:
    print(line)
    i += 1
    if (i > 25):
        break

