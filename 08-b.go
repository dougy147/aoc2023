package main

import "fmt"
import "bufio"
import "os"
//import "reflect"
import "strings"


func main() {
	filepath := "./assets/08.txt"
	content := readfile(filepath)
	directions := content[0]

	counter := 0
	lines := readfile(filepath)[2:]
	hashmap := initialize_hashmap(lines)

	init_states_list := grab_init_states(hashmap) // Find 'xxA' in hashmap
	//fmt.Println("Init A-states are: ", init_states_list)
	z_meeting := make(map[string][]int) // Hashmap with key = init_states, value = Z-encounter

	for i := range init_states_list {
		SP := init_states_list[i]
		init_state := SP

		track := make(map[int][]string)
		var z_indexes []int
		one_turn := false

		for true { // Hope for it to stop
			SP = where(SP, string(directions[counter % len(directions)]), hashmap)
			counter+=1

			if string(SP[2]) == "Z" { z_indexes = append(z_indexes,counter) } // when meet a Z store counter
			if len(track[counter % len(directions)]) == 0 {
				var create_list []string
				create_list = append(create_list, SP)
				var key = counter % len(directions)
				track[key] = create_list
			} else {
				var key = counter % len(directions)
				for i, item := range track[key] {
					_ = i
					if SP == item { one_turn = true }
				}
			}
			if one_turn == true { break }
		}
		//fmt.Println("For init state: ",init_state,", it takes ",counter," steps to make a full turn.")
		//fmt.Println("Meeting, in its course, ending-Z states at indexes: ", z_indexes)
		counter = 0
		z_meeting[init_state] = z_indexes
	}

	//fmt.Println(z_meeting)
	// "Lucky" there's only 1 match by init state
	// Let's compute lowest common divisor to find when the planets will align ;) and we're done

	fmt.Println("Number of steps: ", lowest_common_div(init_states_list, z_meeting))

}

func lowest_common_div(init_states []string, hash map[string][]int) (int){
	// List all Z-indexes
	var zs []int
	for i := range hash {
		for j := range hash[i] { zs = append(zs,hash[i][j]) }
	}
	//fmt.Println("zs: ",zs) // Z-encounters
	power_hashmap := make(map[int]int) // keeps highest power factors
	for i := range zs {
		tmp_powermap := make(map[int]int)
		//fmt.Println(zs[i])
		//fmt.Println(prime_factors(zs[i]))
		// grab prime factors powers
		pfs := prime_factors(zs[i])
		for j := range pfs { tmp_powermap[pfs[j]] += 1 }
		for j := range tmp_powermap {
			if power_hashmap[j] > tmp_powermap[j] { continue }
			power_hashmap[j] = tmp_powermap[j]
		}
	}
	//fmt.Println(power_hashmap)
	lcd := 1
	for x := range power_hashmap { lcd *= x }
	return lcd
}

func prime_factors(n int) ([]int) {
	var factors []int
	i := 2
	for i <= n {
		if n % i == 0 {
			n /= i
			factors = append(factors,i)
			continue
		}
		i+=1
	}
	return factors
}

func grab_init_states(hash map[string][]string) ([]string) {
	var init_states []string
	for key := range hash {
		if string(string(key)[2]) == "A" {
			init_states = append(init_states, string(key))
		}
	}
	return init_states
}

func where(start_point string, direction string, lines map[string][]string) (string) {
	var EPS string
	if direction == "L" {EPS = lines[start_point][0]}
	if direction == "R" {EPS = lines[start_point][1]}
	return EPS
}


func readfile(filepath string) ([]string) {
	file,err := os.Open(filepath) // import file
	_ = err // ignore annoying "'not used' error"
	defer file.Close() // close file...
	var lines []string
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	return lines
}



func initialize_hashmap(lines []string) (map[string][]string) {
	hashmap := make(map[string][]string)

	for i := range lines {
		path := strings.Split(lines[i]," = ")[0]
		dirs := strings.Replace(strings.Replace(strings.Replace(strings.Split(lines[i]," = ")[1]," ", "", -1),"(","",-1),")","",-1)
		left  := strings.Split(dirs,",")[0]
		right := strings.Split(dirs,",")[1]
		var cur_vals []string
		cur_vals = append(cur_vals,left)
		cur_vals = append(cur_vals,right)
		hashmap[path] = cur_vals
	}
	return hashmap
}
