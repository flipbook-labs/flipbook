local function getStories(parent: Instance): { ModuleScript }
	local stories = {}

	for _, descendant in ipairs(parent:GetDescendants()) do
		if descendant.Name:match("%.story$") then
			table.insert(stories, descendant)
		end
	end

	return stories
end

return getStories
