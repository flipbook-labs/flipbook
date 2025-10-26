local function getAncestors(instance: Instance): { Instance }
	local ancestors = {}
	local parent = instance.Parent

	while parent do
		table.insert(ancestors, parent)
		parent = parent.Parent
	end

	return ancestors
end

return getAncestors
