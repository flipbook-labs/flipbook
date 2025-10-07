local Set = require(script.Parent.Parent:WaitForChild('Set'))
local types = require(script.Parent.Parent.Parent:WaitForChild('es7-types'))
local instanceOf = require(script.Parent.Parent.Parent:WaitForChild('instance-of'))
type Array<T> = types.Array<T>
type Set<T> = types.Set<T>
type Table = { [any]: any }

return function(value: Set<any> | Table | string): Array<string>
	if value == nil then
		error("cannot extract keys from a nil value")
	end

	local valueType = typeof(value)

	local keys
	if valueType == "table" then
		keys = {}
		if instanceOf(value, Set) then
			return keys
		end

		for key in pairs(value :: Table) do
			table.insert(keys, key)
		end
	elseif valueType == "string" then
		local length = (value :: string):len()
		keys = table.create(length)
		for i = 1, length do
			keys[i] = tostring(i)
		end
	end

	return keys
end
