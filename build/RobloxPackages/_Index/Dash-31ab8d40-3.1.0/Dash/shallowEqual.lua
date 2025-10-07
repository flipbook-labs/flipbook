--[=[
	Returns `true` if the _left_ and _right_ values are equal (by the equality operator) or the inputs are tables, and all their keys are equal.

	@param left The first value to compare.
	@param right The second value to compare.
	@return `true` if the values are shallowly equal, `false` otherwise.
]=]
local function shallowEqual(left: any, right: any): boolean
	if left == right then
		return true
	end
	if typeof(left) ~= "table" or typeof(right) ~= "table" or #left ~= #right then
		return false
	end
	if left == nil or right == nil then
		return false
	end
	for key, value in left do
		if right[key] ~= value then
			return false
		end
	end
	for key, value in right do
		if left[key] ~= value then
			return false
		end
	end
	return true
end

return shallowEqual
