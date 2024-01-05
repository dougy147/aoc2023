# First time with a functionnal programming language
# Awful implementation but works.

defmodule Read do
  def readfile(filepath) do
    {_ok,content} = File.read(filepath)
    String.split(content,"\n")
  end
end

defmodule Aoc do
  def loop_through_file(filepath) do
    sum = 0
    [head|tail] = Read.readfile(filepath)
    loop_through_file(head,tail,sum)
  end
  defp loop_through_file("",_tail,sum) do
    sum
  end
  defp loop_through_file(head,tail,sum) do
    [springs,damaged] = String.split(head," ")
    damaged = String.split(damaged,",")
    damaged = Enum.map(damaged, fn x-> String.to_integer(x) end)
    sum = sum + count_arrangements(springs,damaged)
    [head|tail] = tail
    loop_through_file(head,tail,sum)
  end

  def count_arrangements(springs,damaged,:start), do: count_arrangements(springs,damaged)
  defp count_arrangements("",damaged) do
    case damaged do
      [] -> 1
      _  -> 0
    end
  end
  defp count_arrangements(springs,[]), do: hashtag_inside(springs)
  defp count_arrangements(springs,damaged) do
    d = Enum.at(damaged,0)
    if d > String.length(springs) do
      0
    else
      case String.slice(springs,0..0) do
        "." ->
          res = count_arrangements(String.slice(springs,1..String.length(springs)),damaged)
          res
        "#" ->
          if String.slice(springs,d..d) == "#" do
            0
          else
            if dot_inside(String.slice(springs,0..d-1)) do
              0
            else
              [ _head | tail ] = damaged
              res = count_arrangements(String.slice(springs,d+1..String.length(springs)),tail)
              res
            end
          end
        "?" ->
          if String.slice(springs,d..d) == "#" do
            count_arrangements(String.slice(springs,1..String.length(springs)),damaged)
          else
            if dot_inside(String.slice(springs,0..d-1)) do
              count_arrangements(String.slice(springs,1..String.length(springs)),damaged)
            else
              [ _head | tail ] = damaged
              res = count_arrangements(String.slice(springs,d+1..String.length(springs)),tail)
              if String.length(springs) == d do
                res
              else
                res = res + count_arrangements(String.slice(springs,1..String.length(springs)),damaged)
                res
              end
            end
          end
      end
    end
  end

  def dot_inside(springs) do
    case String.slice(springs,0..0) do
      "." ->  true
      ""  ->  false
      _   ->  dot_inside(String.slice(springs,1..String.length(springs)))
    end
  end

  def hashtag_inside(springs) do
    case String.slice(springs,0..0) do
      ""  ->  1
      "#" ->  0
      _   ->  hashtag_inside(String.slice(springs,1..String.length(springs)))
    end
  end
end

IO.puts "#{Aoc.loop_through_file("./assets/12.txt")}"
