#!/usr/bin/env rustc
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::collections::HashMap;

fn main() {
    let filepath = "./assets/03.txt";
    let content = BufReader::new(File::open(filepath).expect("Can't open file."));
    let mut result = 0;
    let mut line_index = 0;
    let mut stars_coordinates: Vec<((usize,usize), usize)> = Vec::new(); // list of tuples : [ ((coordinate x, coordinate y), adjacent_number),  ... ]
    for line in content.lines() {
        let line_length = line.as_ref().unwrap().len();
        let mut in_line_index = 0;
        let mut _num_found = false;
        let mut _found_star = false;
        let mut _cur_num = "".to_string();
        let mut _cur_star_coord : (usize,usize) = (0,0);
        for c in line.unwrap().chars() {
            if c.is_numeric() {
                _num_found = true;
                _cur_num.push_str(&String::from(c));
                // check if adjacent star : context = (
                if _found_star == false {
                    let context = checkaround(filepath.to_string(),line_index,in_line_index);
                    if context.0 == true {
                        _found_star = true;
                        _cur_star_coord = context.1;
                    };
                }
            } else {
                if (_num_found == true && _found_star == false) {
                    // we processed a whole number without finding an adjacent star
                    _num_found = false; // discard that number
                    _cur_num = "".to_string();
                    in_line_index += 1;
                    continue;
                } else if (_num_found == true && _found_star == true) {
                    // we processed a whole number and found an adjacent star
                    _found_star = false;
                    _num_found = false;
                    stars_coordinates.push(( _cur_star_coord, _cur_num.parse::<usize>().unwrap() ));
                    _cur_num = "".to_string();
                }
            };
            // if end of line and _num_found and _star_found : append to "stars_coordinates"
            if ( in_line_index >= line_length as isize - 1 && _found_star == true && _num_found == true ) {
                stars_coordinates.push(( _cur_star_coord, _cur_num.parse::<usize>().unwrap() ));
                break;
            };
            in_line_index += 1;
        }
        line_index += 1;
    }
    //println!("Stars coordinates: {:?}", stars_coordinates);

    // Create a hasmap with key = coordinate of found stars, and value: number of time it appears in "stars_coordinates"
    // e.g ((x,y), 5) would mean: the star with coordinates (x,y) has 5 adjacent numbers
    let mut count_in_array: HashMap<(usize,usize), usize> = HashMap::new();
    for ((x,y), number) in &stars_coordinates {
        *count_in_array.entry((*x,*y)).or_insert(0) += 1;
        //println!("Number {} is adjacent to a start with coordinates ({},{}).", number, x,y);
    };


    for ((x,y), &count) in &count_in_array {
        // For stars with EXACTLY two adjacent numbers, multiply those number and add to result.
        if count == 2 {
            //println!("Star with coordinates ({},{}) is a gear.", x, y);
            let mut to_add_to_res = 1;
            for ((a, b), number) in &stars_coordinates {
                if a == x && b == y {
                    //println!("   adjacent number : {}", number);
                    to_add_to_res *= number
                }
            }
            //println!("  multiplication of those adjacent numbers = {}",to_add_to_res);
            result += to_add_to_res;
        }
    };
    println!("Sum of all gear ratios: {}", result);
}


fn checkaround(filepath: String, line_index: isize, char_index: isize) -> (bool, (usize,usize)) {
    let content = BufReader::new(File::open(filepath).expect("Can't open file.")); // TODO: do not reopen file but set 'content' as parameter (what is its type?)
    let mut lindex = 0; // line index
    let mut cindex = 0; // char index
    for line in content.lines() {
        if (lindex >= line_index - 1 && lindex <= line_index + 1) {
            for c in line.unwrap().chars() {
                if (cindex >= char_index - 1 && cindex <= char_index + 1) {
                    if c == '*' {
                        return (true, (lindex as usize,cindex as usize)); // extract '*' coordinates
                    }
                }
                cindex += 1;
            };
        };
        cindex = 0;
        lindex += 1;
    }
    return (false, (0,0));
}
