#!/usr/bin/env ruby

filepath = './assets/09.txt'
lines = File.readlines(filepath, chomp: true) # chomp removes '\n'

list_of_int = []
lines.each { |line| list_of_int.append(line.split(" ").map{|y| Integer(y)}) }

def get_subhistories(history)
  sub_hist = [history]
  cur_hist = history
  while (not are_all_zeroes cur_hist)
    next_hist = []
    for i in 0..cur_hist.length()-1-1
      diff = cur_hist[i+1] - cur_hist[i]
      next_hist.append(diff)
    end
    sub_hist.append(next_hist)
    cur_hist = next_hist
  end
  return sub_hist
end

def are_all_zeroes(array)
  for i in 0..array.length()-1
    if array[i] != 0
      return false
    end
  end
  return true
end

def find_prev_value(array)
  array = array.reverse
  for i in 0..array.length()-1
    if i == 0
      array[i].unshift(0)
      next
    end
    sub = array[i][0] - array[i-1][0]
    array[i].unshift(sub)
  end
  return array[array.length()-1][0]
end


res = 0
list_of_int.each { |history| res += find_prev_value(get_subhistories(history)) }
p res
