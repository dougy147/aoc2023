
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

#print("The animal is at position: $(find_animal(maze))\n")
init_dirs = ["N","S","E","W"]
looped = false
animal_tile = find_animal(maze)

for i in 1:length(init_dirs)
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
			global looped = true
			break
		end
		#print("=> '$(get_symbol(start_point))'=$(start_point) to '$(get_symbol(end_point))'=$(end_point)\n")
		if are_compatible(start_point,end_point)[1] == false
			break
		end
		dir = are_compatible(start_point,end_point)[2]
		#print("should go $(dir) next.\n")
		start_point = end_point
	end
	if looped == false
		continue
	else
		print("Number of steps: $(steps/2)")
		break
	end
end
