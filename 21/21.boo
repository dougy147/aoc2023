import System.IO

filepath = "./assets/21.txt"
garden = List of List of string()
using input = StreamReader(filepath):
    for line in input:
        line = line.Trim()
        to_append = List of string()
        for c in line:
            to_append.Add(c.ToString())
        garden.Add(to_append)

height = len(garden)
width  = len(garden[0])

def copy_garden(garden):
    new_garden = List of List of string()
    for line in garden:
        new_line = List of string()
        for c in line:
            new_line.Add(c.ToString())
        new_garden.Add(new_line)
    return new_garden

def next_garden(garden as List of List of string):
    n_garden = copy_garden(garden)
    for i in range(len(garden)):
        for j in range(len(garden[i])):
            if garden[i][j] == "O" or garden[i][j] == "S":
                x = i
                y = j
                n_garden[x][y] = "."
                if (x - 1 >= 0):
                    if not n_garden[x-1][y] == "#":
                        n_garden[x-1][y] = "O"
                if (x + 1) < height:
                    if not n_garden[x+1][y] == "#":
                        n_garden[x+1][y] = "O"
                if (y - 1) >= 0:
                    if not n_garden[x][y-1] == "#":
                        n_garden[x][y-1] = "O"
                if (y + 1) < width:
                    if not n_garden[x][y+1] == "#":
                        n_garden[x][y+1] = "O"
    return n_garden

def count_plots(garden as List of List of string):
    count = 0
    for line in garden:
        for plot in line:
            if plot == "O":
                count += 1
    return count

for i in range(64):
    garden = next_garden(garden)
print(count_plots(garden))
