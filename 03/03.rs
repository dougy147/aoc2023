#!/usr/bin/env rustc
use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let filepath = "./assets/03.txt";
    let content = BufReader::new(File::open(filepath).expect("Can't open file."));
    let mut result = 0;
    let mut line_index = 0;
    for line in content.lines() {
        let line_length = line.as_ref().unwrap().len();
        let mut in_line_index = 0;
        let mut _num_found = false;
        let mut _adjacent_found = false;
        let mut _cur_num = "".to_string();
        for c in line.unwrap().chars() {
            if c.is_numeric() {
                _num_found = true;
                _cur_num.push_str(&String::from(c));
                // check if there is an adjacent symbol
                if checkaround(filepath.to_string(),line_index,in_line_index) == true {
                    _adjacent_found = true;
                };
            } else {
                if (_num_found == true && _adjacent_found == false) {
                    // we processed a whole number without finding an adjacent
                    _num_found = false; // discard that number
                    _cur_num = "".to_string();
                    in_line_index += 1;
                    continue;
                } else if (_num_found == true && _adjacent_found == true) {
                    // we processed a whole number and found an adjacent
                    _adjacent_found = false;
                    _num_found = false;
                    result += _cur_num.parse::<usize>().unwrap(); // parse needs the type of result (usize)
                    _cur_num = "".to_string();
                }
            };
            // if end of line and _num_found and _adjacent_found: result += _cur_num
            if ( in_line_index >= line_length as isize - 1 && _adjacent_found == true && _num_found == true ) {
                result += _cur_num.parse::<usize>().unwrap();
                break;
            };
            in_line_index += 1;
        }
        line_index += 1;
    }
    println!("The result is: {}", result);
}


fn checkaround(filepath: String, line_index: isize, char_index: isize) -> bool {
    let content = BufReader::new(File::open(filepath).expect("Can't open file.")); // TODO: do not reopen file but set 'content' as parameter (what is its type?)
    let mut lindex = 0; // line index
    let mut cindex = 0; // char index
    for line in content.lines() {
        if (lindex >= line_index - 1 && lindex <= line_index + 1) {
            for c in line.unwrap().chars() {
                if (cindex >= char_index - 1 && cindex <= char_index + 1) {
                    if ! (c.is_numeric() || c == '.') {
                        return true;
                    }
                }
                cindex += 1;
            };
        };
        cindex = 0;
        lindex += 1;
    }
    return false;
}
