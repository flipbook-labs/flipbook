
local function every(list, predicate)
	local listType = type(list)
	assert(listType == "table", "expected a table for first argument, got " .. listType)
	
	local predicateType = type(predicate)
	assert(predicateType == "function", "expected a function for second argument, got " .. predicateType)
	
	for i = 1, #list do
		if not predicate(list[i], i) then
			return false
		end
	end

	return true
end

return every