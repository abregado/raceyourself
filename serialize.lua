
function indextostring(index)
	if type(index) == "number" then
		return string.format("%q",tostring(index))
	else
		return string.format("%q",index)
	end
end

function process(name,data,saved,out)
	out = out or {}
		--Numbers are tostring'd
	if type(data) == "number" then
		local str = "n~"..name.."~"..data.."|"
		table.insert(out,str)
	elseif type(data) == "string" then
		--Strings are store as formated quoted strings
		local str = "s~"..name.."~"..string.format("%q",data).."|"
		table.insert(out,str)
	elseif type(data) == "table" then
		--Look for this table in our saved tables
		local found = false
		for k,v in pairs(saved) do
			if v == data then
				--This table is already defined
				------print("This table is already defined, storing reference name")
				local str = "t~"..name..":"..k.."~|"
				table.insert(out,str)
				found = true
			end
		end
		if not found then
			--Define table
			saved[name] = data
			local str = "t~"..name.."~{|"
			local this = {}
			for k,v in pairs(data) do
				--Serialize each internal element
				table.insert(this,stage(v,indextostring(k),saved))
			end
			str = str .. table.concat(this) .. "}|"
			table.insert(out,str)
		end
	end
	return out
end

--Given a number,string or table, returns a string for rebuilding it
-- Supports numbers, strings, tables and nested tables, but doesn't support
-- functions
function stage(data,name,saved)
	saved = saved or {}
	name = name or indextostring("data")
	local out = process(name,data,saved)
	str = table.concat(out)
	----print(out)
	return str
end

function serialize(data,name,saved)
	local str = stage(data,name,saved)
	return string.sub(str,1,-2)..".|"
end

function getWords(str)
	local out = {}
	local t = {}
	local i = 0
	while true do
	  i = string.find(str, "|", i+1)    -- find spaces
	  if i == nil then break end
	  table.insert(t, i)
	end
	local j = 0
	for k,v in pairs(t) do
		table.insert(out,string.sub(str,j,v))
		j=v+1
	end
	return out
end



function analizeWords(data)
	curtable = {}
	saved = {}
	curtable.tab = {}
	curtable.prev = false
	define = false
	--for k,v in pairs(data) do --print(k,v) end
	--print("Begin deserialize")
	for k,v in pairs(data) do
		if v == "}|" then
			--print("Moving from table " .. tostring(curtable) .. " to parent " .. tostring(curtable.prev))
			curtable = curtable.prev
			--print("Reached end of table")
		elseif v=="}.|" then
			--print("Ended")
			return curtable.tab
		elseif string.sub(v,1,2) == "t~" then
			----print(v)
			local e,_ = string.find(v,"~",3)
			local name = string.sub(v,4,e-2)
			if name ~= "" then
				local number = tonumber(name)
				if number then
					name=number
				end
			else
				name = #curtable.tab
			end
			----print("Table found: " .. name)
			local image
			
			local c,_ = string.find(v,":")		
			if c then
				define = false
				image = string.sub(name,c-1,-1)
				name = string.sub(name,1,c-5)
				----print("Table " .. name .. " claims to be defined as " .. image)
				for k,v in pairs(saved) do
					----print(k,v)
				end
				----print("This table holds " .. #saved[image] .. " elements")
				curtable.tab[name] = saved[image]
			else
				define = true
				--Create a new table entry
				saved[name] = {}
				--print("New table defined: " .. name)
				--Create a new current table
				newtable = {}
				--Set this current table property to the new saved table
				newtable.tab = saved[name]
				--Insert this new table in the current table
				--table.insert(current.table,name,newtable.table)
				curtable.tab[name] = newtable.tab
				
				--Asign the new curtable previous property to the previous table
				newtable.prev = curtable
				--Move on to the new current table
				--print("Moving from parent " .. tostring(curtable) .. " to sub-table " .. tostring(newtable))
				curtable = newtable
			end
		elseif string.sub(v,1,2) == "n~" then
			local e,_ = string.find(v,"~",3)
			local name = string.sub(v,4,e-2)
			local value = string.sub(v,e+1,-2)
			local number = tonumber(name)
			if number then
				name = number
			end
			curtable.tab[name] = value
			--print("curtable.table["..name.."] = "..curtable.tab[name])
		elseif string.sub(v,1,2) == "s~" then
			local e,_ = string.find(v,"~",3)
			local name = string.sub(v,4,e-2)
			local value = string.sub(v,e+2,-3)
			--print("String found " .. name .. " = " .. value)
			if name ~= "" then
				local number = tonumber(name)
				if number then
					curtable.tab[number] = value
				else
					curtable.tab[name] = value
				end
			else
				table.insert(curtable.tab,value)
			end
		end
		--print("Current state of curtable: ")
		for k,v in pairs(curtable.tab) do
			--print(k,v)
		end
	end
	--print("Something weird happened, returning nil")
	return nil
end

function deserialize(str)
	return analizeWords(getWords(str))
end
