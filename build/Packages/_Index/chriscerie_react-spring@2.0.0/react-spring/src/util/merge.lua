local function merge(...)
	local new = {}

	for dictionaryIndex = 1, select("#", ...) do
		local dictionary = select(dictionaryIndex, ...)

		if dictionary ~= nil then
			for key, value in pairs(dictionary) do
				new[key] = value
			end
		end
	end

	return new
end

return merge
