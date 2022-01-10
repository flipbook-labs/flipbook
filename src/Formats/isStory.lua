local function isStory(object: any)
	return typeof(object) == "table" and object.story ~= nil
end

return isStory
