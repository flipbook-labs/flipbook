--[[
	Provides functions for comparing and printing lua tables.
]]

local TableUtilities = {}
local defaultIgnore = {}

local function makeKeyString(key)
	if type(key) == "string" then
		return string.format("%s", key)
	else
		return string.format("[%s]", tostring(key))
	end
end

local function makeValueString(value)
	local valueType = type(value)
	if valueType == "string" then
		return string.format("%q", value)
	elseif valueType == "function" or valueType == "table" then
		return string.format("<%s>", tostring(value))
	else
		return string.format("%s", tostring(value))
	end
end

local function printKeypair(key, value, indentStr, comment)
	local keyString = makeKeyString(key)
	local valueString = makeValueString(value)

	local commentStr = if comment then string.format(" -- %s", comment) else ""
	print(string.format("%s%s = %s,%s", indentStr, keyString, valueString, commentStr))
end

--[[
	Takes two tables A and B, returns if they have the same key-value pairs
	Except ignored keys
]]
function TableUtilities.ShallowEqual(A, B, ignore)
	if not A or not B then
		return false
	elseif A == B then
		return true
	end

	if not ignore then
		ignore = defaultIgnore
	end

	for key, value in A do
		if B[key] ~= value and not ignore[key] then
			return false
		end
	end
	for key, value in B do
		if A[key] ~= value and not ignore[key] then
			return false
		end
	end

	return true
end

local function formatDeepEqualMessage(message, level)
	if level ~= 0 then
		return message
	end

	return message:gsub("{1}", "first"):gsub("{2}", "second")
end

--[[
	Takes two tables A and B, returns if they have the same key-value pairs recursively
]]
function TableUtilities.DeepEqual(a, b, level)
	level = level or 0
	if a == b then
		return true
	end

	if typeof(a) ~= typeof(b) then
		local message = ("{1} is of type %s, but {2} is of type %s"):format(typeof(a), typeof(b))

		return false, formatDeepEqualMessage(message, level)
	end

	if typeof(a) == "table" then
		local visitedKeys = {}

		for key, value in a do
			visitedKeys[key] = true

			local success, innerMessage = TableUtilities.DeepEqual(value, b[key], level + 1)
			if not success then
				local message = innerMessage
					:gsub("{1}", ("{1}[%s]"):format(tostring(key)))
					:gsub("{2}", ("{2}[%s]"):format(tostring(key)))

				return false, formatDeepEqualMessage(message, level)
			end
		end

		for key, value in b do
			if not visitedKeys[key] then
				local success, innerMessage = TableUtilities.DeepEqual(a[key], value, level + 1)

				if not success then
					local message = innerMessage
						:gsub("{1}", ("{1}[%s]"):format(tostring(key)))
						:gsub("{2}", ("{2}[%s]"):format(tostring(key)))

					return false, formatDeepEqualMessage(message, level)
				end
			end
		end

		return true
	end

	local message = "{1} ~= {2}"
	return false, formatDeepEqualMessage(message, level)
end

--[[
	Takes two tables A, B and a key, returns if two tables have the same value at key
]]
function TableUtilities.EqualKey(A, B, key)
	if A and B and key and key ~= "" and A[key] and B[key] and A[key] == B[key] then
		return true
	end
	return false
end

--[[
	Takes two tables A and B, returns a new table with elements of A
	which are either not keys in B or have a different value in B
]]
function TableUtilities.TableDifference(A, B)
	local new = {}

	for key, value in A do
		if B[key] ~= A[key] then
			new[key] = value
		end
	end

	return new
end

--[[
	Takes a list and returns a table whose
	keys are elements of the list and whose
	values are all true
]]
local function membershipTable(list)
	local result = {}
	for i = 1, #list do
		result[list[i]] = true
	end
	return result
end

--[[
	Takes a table and returns a list of keys in that table
]]
local function listOfKeys(t)
	local result = {}
	for key, _ in t do
		table.insert(result, key)
	end
	return result
end

--[[
	Takes two lists A and B, returns a new list of elements of A
	which are not in B
]]
function TableUtilities.ListDifference(A, B)
	return listOfKeys(TableUtilities.TableDifference(membershipTable(A), membershipTable(B)))
end

--[[
	For debugging.  Returns false if the given table has any of the following:
		- a key that is neither a number or a string
		- a mix of number and string keys
		- number keys which are not exactly 1..#t
]]
function TableUtilities.CheckListConsistency(t)
	local containsNumberKey = false
	local containsStringKey = false
	local numberConsistency = true

	local index = 1
	for x, _ in t do
		if type(x) == "string" then
			containsStringKey = true
		elseif type(x) == "number" then
			if index ~= x then
				numberConsistency = false
			end
			containsNumberKey = true
		else
			return false
		end

		if containsStringKey and containsNumberKey then
			return false
		end

		index = index + 1
	end

	if containsNumberKey then
		return numberConsistency
	end

	return true
end

--[[
	For debugging, serializes the given table to a reasonable string that might even interpret as lua.
]]
function TableUtilities.RecursiveToString(t, indent)
	indent = indent or ""

	if type(t) == "table" then
		local result = ""
		if not TableUtilities.CheckListConsistency(t) then
			result = result .. "-- WARNING: this table fails the list consistency test\n"
		end
		result = result .. "{\n"
		for k, v in t do
			if type(k) == "string" then
				result = result
					.. "  "
					.. indent
					.. tostring(k)
					.. " = "
					.. TableUtilities.RecursiveToString(v, "  " .. indent)
					.. ";\n"
			end
			if type(k) == "number" then
				result = result .. "  " .. indent .. TableUtilities.RecursiveToString(v, "  " .. indent) .. ",\n"
			end
		end
		result = result .. indent .. "}"
		return result
	else
		return tostring(t)
	end
end

--[[
	For debugging. Prints the table on multiple lines to overcome log-line length
	limitations which are otherwise necessary for performance. Use sparingly.
]]
function TableUtilities.Print(t, indent)
	indent = indent or "  "

	if type(t) ~= "table" then
		error("TableUtilities.Print must be passed a table", 2)
	end

	-- For cycle detection
	local printedTables = {}

	local function recurse(subTable, tableKey, level)
		-- Prevent cycles by keeping track of what tables we have printed
		printedTables[subTable] = true

		local indentStr = string.rep(indent, level)
		local valueIndentStr = string.rep(indent, level + 1)

		if tableKey then
			print(string.format("%s%s = %s {", indentStr, makeKeyString(tableKey), makeValueString(subTable)))
		else
			print(string.format("%s%s {", indentStr, makeValueString(subTable)))
		end

		for key, value in subTable do
			if type(value) == "table" then
				if printedTables[value] then
					printKeypair(key, value, valueIndentStr, "Possible cycle")
				else
					recurse(value, key, level + 1)
				end
			else
				printKeypair(key, value, valueIndentStr)
			end
		end

		print(string.format("%s}%s", indentStr, (if level > 0 then "," else "")))
	end

	recurse(t, nil, 0)
end

--[[
    Takes a table and returns the field count
]]
function TableUtilities.FieldCount(t)
	local fieldCount = 0
	for _ in t do
		fieldCount = fieldCount + 1
	end
	return fieldCount
end

return TableUtilities
