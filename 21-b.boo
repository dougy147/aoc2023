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

states = List of List of List of string()

def count(garden as List of List of string, style as string):
    if style == "even-fill":
        step = 1 * (65) + 2 * (65+66)
    elif style == "odd-fill":
        step = 1 * (65) + 3 * (65+66)
    elif style == "border":
        step = 1 * (65+66)
    elif style == "corner":
        step = 1 * (65) + 1*(65+66)
    elif style == "corner-half":
        step = 1 * (65)
    index = 0
    while true:
        if step == 1:
            break
        garden = next_garden(garden)
        step -= 1
        if garden in states:
            index += 1
        states.Add(garden)
    return count_plots(garden)

full_fill_even = count(garden,"even-fill")
full_fill_odd  = count(garden,"odd-fill")

garden[65][65] = "."
garden[0][65] = "S"
midup = count(garden,"border")

garden[0][65] = "."
garden[height-1][65] = "S"
midbot = count(garden,"border")

garden[height-1][65] = "."
garden[65][0] = "S"
midleft = count(garden,"border")

garden[65][0] = "."
garden[65][width-1] = "S"
midright = count(garden,"border")

garden[65][width-1] = "."
garden[0][0]  = "S"
topleft = count(garden,"corner")

garden[0][0] = "."
garden[0][width-1]  = "S"
topright = count(garden,"corner")

garden[0][width-1] = "."
garden[height-1][0]  = "S"
botleft = count(garden,"corner")

garden[height-1][0] = "."
garden[height-1][width-1]  = "S"
botright = count(garden,"corner")

garden[height-1][width-1] = "."
garden[0][0]  = "S"
halftopleft = count(garden,"corner-half")

garden[0][0] = "."
garden[0][width-1]  = "S"
halftopright = count(garden,"corner-half")

garden[0][width-1] = "."
garden[height-1][0]  = "S"
halfbotleft = count(garden,"corner-half")

garden[height-1][0] = "."
garden[height-1][width-1]  = "S"
halfbotright = count(garden,"corner-half")

# Number of traversed "garden" in one direction after 26501365 - 65 steps
t as ulong = (26501365 - 65) / 131

# "Formulas" to compute this insane number (extracted from pen and paper :p)
filled_quarter_maps as ulong = 0
for i in range(1,(t-2+1)):
    filled_quarter_maps+=i

odd_filled_in_quarter as ulong = (filled_quarter_maps - ((t-2)/2)) / 2 # 10231120201
even_filled_in_quarter as ulong = filled_quarter_maps - odd_filled_in_quarter #10231221350

total as ulong = ((t - 2) * full_fill_odd) + (t * full_fill_even) + ((t - 1) * full_fill_odd) + (t * full_fill_even) + midup + midbot + midright + midleft + ( 4 * odd_filled_in_quarter * full_fill_odd) + (4 * even_filled_in_quarter * full_fill_even) + (t * halftopleft) + ((t-1) * topleft) + (t * halftopright) + ((t-1) * topright) + (t * halfbotleft) + ((t-1) * botleft) + (t * halfbotright) + ((t-1) * botright)
print(total)
