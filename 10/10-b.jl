
filepath = "./assets/10.txt"
maze = readlines(filepath)

width  = length(maze[1])
height = length(maze)

directions = Dict(
		  "|"=> ("N","S"),
		  "-"=> ("W","E"),
		  "L"=> ("N","E"),
		  "J"=> ("N","W"),
		  "7"=> ("W","S"),
		  "F"=> ("E","S"),
		  "."=> ("x","x"),
		  "S"=> ("?","?")
		  )

function next_coord(coordinates,orientation)
	if orientation == "N"
		return (coordinates[1]-1,coordinates[2])
	elseif orientation == "S"
		return (coordinates[1]+1,coordinates[2])
	elseif orientation == "E"
		return (coordinates[1],coordinates[2]+1)
	elseif orientation == "W"
		return (coordinates[1],coordinates[2]-1)
	end
	return (-1,-1)
end

function get_dirs(tile)
	return directions[string(get_symbol(tile))]
end

function get_symbol(tile)
	x,y = tile
	return maze[x][y]
end

function are_compatible(sp,ep)
	if is_valid_coord(sp) == false || is_valid_coord(ep) == false
		return (false,"")
	end
	x_diff = ep[1] - sp[1]
	y_diff = ep[2] - sp[2]
	if x_diff > 0
		prev_pos = "N"
	elseif x_diff < 0
		prev_pos = "S"
	end
	if y_diff > 0
		prev_pos = "W"
	elseif y_diff < 0
		prev_pos = "E"
	end
	cur_dirs = get_dirs(ep)
	if     prev_pos == cur_dirs[1]
		return (true,cur_dirs[2])
	elseif prev_pos == cur_dirs[2]
		return (true,cur_dirs[1])
	else
		return (false,"")
	end
end

function is_valid_coord(coords)
	if coords[1] < 1 || coords[1] > height
		return false
	elseif coords[2] < 1 || coords[2] > width
		return false
	else
		return true
	end
end

function find_animal(maze)
	for i in 1:height
		for j in 1:width
			if maze[i][j] == 'S'
				return (i,j)
			end
		end
	end
end

function inverse(d) # give inverse of direction (overkill...)
	if d == "N"
		return "S"
	elseif d == "S"
		return "N"
	elseif d == "E"
		return "W"
	elseif d == "W"
		return "E"
	end
end

function get_S_symbol(x,y)
	for (k,v) in directions
		if (x == v[1] && y == v[2]) || (x == v[2] && y == v[1])
			return k
		end
	end
end

#print("The animal is at position: $(find_animal(maze))\n")
init_dirs = ["N","S","E","W"]
looped = false
animal_tile = find_animal(maze)

for i in 1:length(init_dirs)
	only_pipes_maze = fill("",height,width)
	start_point = animal_tile
	dir = init_dirs[i]
	#print("\nGoing $(init_dirs[i]) from '$(get_symbol(animal_tile))' pos=$(animal_tile)\n")
	steps = 0
	while looped == false
		steps += 1
		end_point = next_coord(start_point,dir)
		if is_valid_coord(end_point) == false
			break
		end
		if get_symbol(end_point) == 'S'
			#print("\nS should have directions '$(init_dirs[i])' and '$(inverse(dir))'\n")
			#print("S corresponds to symbol '$(get_S_symbol(init_dirs[i],inverse(dir)))'\n")
			only_pipes_maze[animal_tile[1],animal_tile[2]] = string(get_S_symbol(init_dirs[i],inverse(dir)))
			only_pipes_maze[start_point[1],start_point[2]] = string(get_symbol(start_point))
			global looped = true
			break
		end
		if are_compatible(start_point,end_point)[1] == false
			break
		end
		dir = are_compatible(start_point,end_point)[2]
		only_pipes_maze[start_point[1],start_point[2]] = string(get_symbol(start_point))
		start_point = end_point
	end
	if looped == false
		continue
	else
		#print("Number of steps: $(steps/2)\n")
		global new_maze = only_pipes_maze
		break
	end
end

# How to treat states:
# 1. Always starts a new line with "OUTSIDE" state
# 2. When meeting pipes:
#     a.   "|" : always switch state (OUTSIDE <-> INSIDE)
#     b.   "-" : always ignore state (OUTSIDE == OUTSIDE)
#     c.   "L" : switch state until :
#                -> "J" : switch state
#                -> "7" : ignore
#     d.   "F" : switch state until :
#                -> "J" : ignore
#                -> "7" : switch state

counter = 0
for i in 1:size(new_maze,1)
	STATE = false
	SUBSTATE = ""
	for j in 1:size(new_maze,2)
		if new_maze[i,j] == "|"
			STATE = ! STATE
		elseif new_maze[i,j] == "L"
			STATE = ! STATE
			SUBSTATE = "L"
		elseif new_maze[i,j] == "F"
			STATE = ! STATE
			SUBSTATE = "F"
		elseif new_maze[i,j] == "J"
			if SUBSTATE == "L"
				STATE = ! STATE
			end
		elseif new_maze[i,j] == "7"
			if SUBSTATE == "F"
				STATE = ! STATE
			end
		elseif new_maze[i,j] == ""
			if STATE == true
				global counter += 1
			end
		end
	end
end

print("Number of enclosed tiles: $(counter)")
