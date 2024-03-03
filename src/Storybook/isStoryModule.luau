local flipbook = script:FindFirstAncestor("flipbook")

local constants = require(flipbook.constants)

local function isStoryModule(instance: Instance)
	if instance:IsA("ModuleScript") and instance.Name:match(constants.STORY_NAME_PATTERN) then
		return true
	end
	return false
end

return isStoryModule
