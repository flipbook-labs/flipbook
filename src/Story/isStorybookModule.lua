local flipbook = script:FindFirstAncestor("flipbook")

local constants = require(flipbook.constants)

local function isStorybookModule(instance: Instance): boolean
	return instance:IsA("ModuleScript") and instance.Name:match(constants.STORYBOOK_NAME_PATTERN) ~= nil
end

return isStorybookModule
