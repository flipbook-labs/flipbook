local function trim(value: string): string
	return value:match("^%s*(.-)%s*$") or value
end

local function doesTreeNodeMatchSearch(nodeName: string, searchTerm: string): boolean
	local normalizedNodeName = nodeName:lower()

	for _, alternative in searchTerm:split("|") do
		local normalizedAlternative = trim(alternative):lower()
		if normalizedAlternative ~= "" and normalizedNodeName:find(normalizedAlternative, 1, true) then
			return true
		end
	end

	return false
end

return doesTreeNodeMatchSearch
