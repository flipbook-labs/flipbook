local function isHoarcekatStory(story: any)
	return typeof(story) == "function"
end

return isHoarcekatStory
