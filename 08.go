package main

import "fmt"
import "bufio"
import "os"
import "strings"


func main() {
	filepath := "./assets/08.txt"
	content := readfile(filepath)
	directions := content[0]

	lines := readfile(filepath)[2:]
	hashmap := initialize_hashmap(lines)

	SP := "AAA"
	EP := "ZZZ"

	counter := 0

	for SP != EP {
		SP = where(SP, string(directions[counter % len(directions)]), hashmap)
		counter+=1
	}
	fmt.Println(counter)
}

func where(start_point string, direction string, lines map[string][]string) (string) {
	var EPS string // end point states
	if direction == "L" {EPS = lines[start_point][0]}
	if direction == "R" {EPS = lines[start_point][1]}
	return EPS
}

func readfile(filepath string) ([]string) {
	file,err := os.Open(filepath) // import file
	_ = err // ignore annoying "'not used' error"
	defer file.Close()
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
