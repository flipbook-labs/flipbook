local function isLegacyStory(story: any)
	if typeof(story) == "function" then
		local _success, result = pcall(story)

		if typeof(result) == "function" then
			return true
		end
	end
	return false
end

return isLegacyStory
