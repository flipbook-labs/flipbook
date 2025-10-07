local function hasPermission(instance: Instance)
	local success = pcall(function()
		return instance.Name
	end)
	return success
end

local function matchDescendants(parent: Instance, predicate: (descendant: Instance) -> boolean): { Instance }
	local matches = {}

	if not hasPermission(parent) then
		return matches
	end

	for _, descendant in parent:GetDescendants() do
		local success, result = pcall(function()
			return predicate(descendant)
		end)

		if success and result == true then
			table.insert(matches, descendant)
		end
	end

	return matches
end

return matchDescendants
