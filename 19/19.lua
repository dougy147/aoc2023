filepath = "./assets/19.txt"
file = io.open(filepath)
lines = file:lines()

reached_parts = false
workflows = {}
parts = {}
for line in lines do
  if line == "" then
    reached_parts = true
    goto continue
  end
  if not reached_parts then
    label = string.gsub(line, "(.*){(.*)}", "%1")
    rest = string.gsub(line, "(.*){(.*)}", "%2")
    statements = {}
    for i in string.gmatch(rest,"([^,]+)") do
      table.insert(statements,i)
    end
    workflows[label] = statements
  else
    line = string.gsub(line, "{(.*)}", "%1")
    if line == "" then
      goto continue
    end
    xmas = {}
    for v in string.gmatch(line,"([^,]+)") do
      id  = string.gsub(v,"(.*)=(.*)", "%1")
      val = string.gsub(v,"(.*)=(.*)", "%2")
      xmas[id] = val
    end
    --parts[xmas] = ""
    table.insert(parts,xmas)
  end
  ::continue::
end

function identify_statements (statement)
  if string.match(statement,":") then
    return "condition"
  else
    return "action"
  end
end

function execute_statement (instructions, part)
  x,m,a,s = tonumber(part['x']),tonumber(part['m']),tonumber(part['a']),tonumber(part['s'])
  while not (next(instructions) == nil) do
    st = instructions[1]
    if identify_statements (st) == "condition" then
      test_eval = load("return " .. string.gsub(st,"(.*):(.*)","%1"))
      if test_eval() then
	res = string.gsub(st,"(.*):(.*)","%2")
      	if res == "A" then
      	  return true
      	end
      	if res == "R" then
      	  return false
      	end
      	return execute_statement(workflows[res],part)
      else
        instructions = {table.unpack(instructions,2)}
      end
    else
      if st == "A" then
	return true
      end
      if st == "R" then
	return false
      end
      return execute_statement(workflows[st],part)
    end
  end
end

function val_part(part)
  return part['x'] + part['m'] + part['a'] + part['s']
end

init = workflows['in']
sum_accepted = 0

for index,part in pairs(parts) do
  while true do
    res = execute_statement(init,part)
    if res == true then
      --print("[ACCEPTED] part", part)
      sum_accepted = sum_accepted + val_part(part)
      break
    end
    if res == false then
      --print("[REJECTED] part", part)
      break
    end
  end
end
print(sum_accepted)
