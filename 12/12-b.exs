# First time with a functionnal programming language
# Awful implementation but works.

defmodule Read do
  def readfile(filepath) do
    {_ok,content} = File.read(filepath)
    String.split(content,"\n")
  end
end

defmodule Bigmap do # store args and results of count_arrangements functions
 def start_link do
   Agent.start_link(fn -> %{} end, name: __MODULE__)
 end
 def get_map do
   Agent.get(__MODULE__, & &1)
 end
 def put_in_map(key, value) do
   Agent.update(__MODULE__, &Map.put(&1, key, value))
 end
end

defmodule Memoize do
  def memoize(springs,damaged) do
    ## concatenate springs:damaged to string
    key = springs <> Enum.join(Enum.map(damaged, &Kernel.to_string/1), ",")

    case Bigmap.get_map() do
      %{^key => res} -> res
      _ ->
        res = Aoc.count_arrangements(springs,damaged,:start)
        Bigmap.put_in_map(key, res)
        res
    end
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
    damaged = Enum.map(damaged, fn x -> String.to_integer(x) end)
    springs = String.duplicate(springs <> "?", 4) <> springs
    damaged = damaged ++ damaged ++ damaged ++ damaged ++ damaged
    res = Memoize.memoize(springs,damaged)
    IO.puts res
    #res = count_arrangements(springs,damaged)
    sum = sum + res
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
          #res = count_arrangements(String.slice(springs,1..String.length(springs)),damaged)
          res = Memoize.memoize(String.slice(springs,1..String.length(springs)),damaged)
          res
        "#" ->
          if String.slice(springs,d..d) == "#" do
            0
          else
            if dot_inside(String.slice(springs,0..d-1)) do
              0
            else
              [ _head | tail ] = damaged
              res = Memoize.memoize(String.slice(springs,d+1..String.length(springs)),tail)
              res
            end
          end
        "?" ->
          if String.slice(springs,d..d) == "#" do
            Memoize.memoize(String.slice(springs,1..String.length(springs)),damaged)
          else
            if dot_inside(String.slice(springs,0..d-1)) do
              Memoize.memoize(String.slice(springs,1..String.length(springs)),damaged)
            else
              [ _head | tail ] = damaged
              res = Memoize.memoize(String.slice(springs,d+1..String.length(springs)),tail)
              if String.length(springs) == d do
                res
              else
                res = res + Memoize.memoize(String.slice(springs,1..String.length(springs)),damaged)
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

{:ok, _} = Bigmap.start_link()
res = Aoc.loop_through_file("./assets/12.txt")
IO.puts res
