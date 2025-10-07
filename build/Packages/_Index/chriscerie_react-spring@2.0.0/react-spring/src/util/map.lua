local function map(dictionary, fn)
	local new = {}

	for key, value in pairs(dictionary) do
		local newValue, newKey = fn(value, key)
		new[newKey or key] = newValue
	end

	return new
end

return map
