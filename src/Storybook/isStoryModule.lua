local flipbook = script:FindFirstAncestor("flipbook")

local constants = require(flipbook.constants)

local function isStoryModule(instance: Instance)
	if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then
		if instance:IsA("ModuleScript") and instance.Name:match(constants.STORY_NAME_PATTERN_CSF) then
			return true
		end
	else
		if instance:IsA("ModuleScript") and instance.Name:match(constants.STORY_NAME_PATTERN) then
			return true
		end
	end
	return false
end

return isStoryModule
