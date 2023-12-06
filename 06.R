
filepath <- "./assets/06.txt"

import_file <- function(f) {
	content <- c(read.delim(f,header = F, sep = "\n"))
	return (content)
}

list_races <- function(content) { # outputs a list of race (time,record)
	races_list <- list()
	races_time <- strsplit(content[[1]][1], split = "\\s+")
	races_record <- strsplit(content[[1]][2], split = "\\s+")
	for (x in 2:(length(races_record[[1]]))) {
		cur_list <- list(races_time[[1]][x],races_record[[1]][x]);
		races_list <- append(races_list,list(cur_list))
	}
	return(races_list)
}

compute_ways <- function(duration, record) {
	ways = 0
	for (x in 1:(duration-1)) {
		# distance if button pressed x milliseconds
		distance <- (duration - x) * x
		if (distance > record) {
		    ways = ways + 1
		}
	}
	return (ways)
}

count_ways <- function(list_races) { # outputs the multiplciation of ways
	mult = 1
	for ( race in 1:length(list_races)) {
		duration <- strtoi(list_races[[race]][1])
		record   <- strtoi(list_races[[race]][2])
		mult = mult * compute_ways(duration,record)
	}
	return(mult)
}

content <- import_file(filepath);
count_ways(list_races(content))
