filepath = "./assets/19.txt"
file = io.open(filepath)
lines = file:lines()

reached_parts = false
workflows = {}
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
    break
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

function effect_on (test)
  if string.match(test,"x") then
    return 1
  elseif string.match(test,"m") then
    return 2
  elseif string.match(test,"a") then
    return 3
  elseif string.match(test,"s") then
    return 4
  end
end

function execute_statement (instructions, part)
  if #part == 0 or #instructions == 0 then
    return
  end
  -- print("Executing instructions",instructions, "on part", part)
  st = instructions[1]
  if identify_statements (st) == "condition" then
    test_eval = string.gsub(st,"(.*):(.*)","%1")
    effect = effect_on(test_eval)
    res = string.gsub(st,"(.*):(.*)","%2")
    local new_p_true  = {}
    local new_p_false = {}
    if string.match(test_eval,"<") then
      val = string.gsub(test_eval,"(.*)<(.*)","%2")
      val = tonumber(val)
      x = part[effect][1]
      y = part[effect][2]
      if y < val then
	new_p_true = part
      elseif x >= val then
	new_p_false = part
      elseif x < val then
	s0 = {x,val-1}
	s1 = {val,y}
	for i=1,#part do
	  if i == effect then
	    table.insert(new_p_true,s0)
	  else
	    table.insert(new_p_true,part[i])
	  end
	end
	for i=1,#part do
	  if i == effect then
	    table.insert(new_p_false,s1)
	  else
	    table.insert(new_p_false,part[i])
	  end
	end
      end
      if res == "A" then
	count = count + poss(new_p_true)
	execute_statement({table.unpack(instructions,2)},new_p_false)
	return
      elseif res == "R" then
	execute_statement({table.unpack(instructions,2)},new_p_false)
	return
      else
	execute_statement(workflows[res],new_p_true)
	execute_statement({table.unpack(instructions,2)},new_p_false)
      end
    elseif string.match(test_eval,">") then
      val = string.gsub(test_eval,"(.*)>(.*)","%2")
      val = tonumber(val)
      x = part[effect][1]
      y = part[effect][2]
      if y <= val then
	new_p_false = part
      elseif x > val then
	new_p_true = part
      elseif x < val then
	s1 = {x,val}
	s0 = {val+1,y}
	for i=1,#part do
	  if i == effect then
	    table.insert(new_p_true,s0)
	  else
	    table.insert(new_p_true,part[i])
	  end
	end
	for i=1,#part do
	  if i == effect then
	    table.insert(new_p_false,s1)
	  else
	    table.insert(new_p_false,part[i])
	  end
	end
      end
      if res == "A" then
	count = count + poss(new_p_true)
	execute_statement({table.unpack(instructions,2)},new_p_false)
	return
      elseif res == "R" then
	execute_statement({table.unpack(instructions,2)},new_p_false)
	return
      else
	execute_statement(workflows[res],new_p_true)
	execute_statement({table.unpack(instructions,2)},new_p_false)
      end
    end
  else
    if st == "A" then
      count = count + poss(part)
      return
    end
    if st == "R" then
      return
    end
    return execute_statement(workflows[st],part)
  end
end

count = 0
max_val = 4000 ^ 4

function poss (interval)
  if #interval == 0 then
    return 0
  end
  local poss = 1
  for k,p in pairs(interval) do
    poss = poss * ((p[2] - p[1]) + 1)
  end
  return poss
end

part = {{1,4000},{1,4000},{1,4000},{1,4000}}
init = workflows['in']
execute_statement(init,part)
print(count)
