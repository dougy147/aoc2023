
filepath <- "./assets/06.txt"

duration = 40817772
record   = 219101213651089

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

compute_ways(duration,record)
