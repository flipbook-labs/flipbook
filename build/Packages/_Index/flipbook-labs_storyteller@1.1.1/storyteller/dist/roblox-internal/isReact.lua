--[[
	This function is used to differentiate between React and legacy Roact only
	for the consumption of Roblox Internal storybooks.
]]
local function isReact(maybeReact: any): boolean
	if maybeReact.Ref == "ref" and maybeReact.Children == "children" then
		return true
	-- Legacy Roact is a strict table, and indexing it directly throws an error
	-- if a member doesn't exist. To get around this we use rawget to check if
	-- it's React
	elseif rawget(maybeReact, "useState") ~= nil then
		return true
	else
		return false
	end
end

return isReact
