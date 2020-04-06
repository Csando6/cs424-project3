from os import path

#if your file is in the same directory:
#filename = 'release-dates.list'
#file = open(filename)

#if your file is within LIST_files
filepath = path.relpath("LIST_files/release-dates.list")
with open(filepath) as file:

    #get first few lines to start out:
    i = 0
    while i < 25:
        print(file.readline())
        i += 1

