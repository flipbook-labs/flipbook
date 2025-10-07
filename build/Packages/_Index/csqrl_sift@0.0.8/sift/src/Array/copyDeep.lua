--!strict
--[=[
	@function copyDeep
	@within Array

	@param array {T} -- The array to copy.
	@return {T} -- The copied array.

	Copies an array, with deep copies of all nested arrays.

	```lua
	local array = { 1, 2, 3, { 4, 5 } }

	local result = CopyDeep(array) -- { 1, 2, 3, { 4, 5 } }

	print(result == array) -- false
	print(result[4] == array[4]) -- false
	```
]=]
local function copyDeep<T>(array: { T }): { T }
	local result = table.clone(array)

	for index, value in array do
		if type(value) == "table" then
			result[index] = copyDeep(value) :: any
		end
	end

	return result
end

return copyDeep
