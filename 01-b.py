#!/usr/bin/env python3

accepted_digits = {
        "one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6, "seven": 7, "eight": 8, "nine": 9, "0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9
}

#accepted_sorted = [x for x in sorted(accepted_digits, key=lambda x: len(x), reverse = True)]

def read_forward(line: str) -> int:
    while len(line) > 0:
        for digit in accepted_digits.keys():
            if line[0:len(digit)] == digit: return accepted_digits[digit]
        line = line[1:]
    return 0

def read_backward(line: str) -> str:
    while len(line) > 0:
        for digit in accepted_digits.keys():
            if line[-len(digit):] == digit: return accepted_digits[digit]
        line = line[:-1]
    return 0

result = 0
with open("./assets/01.txt", 'r') as f:
    for line in f.readlines():
        num1 = read_forward(line)
        num2 = read_backward(line)
        num3 = str(num1) + str(num2)
        #print(f"{num1}{num2} : line '{line}'")
        result += int(num3)
print(result)
