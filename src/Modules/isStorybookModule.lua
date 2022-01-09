local constants = require(script.Parent.Parent.constants)

local function isStorybookModule(instance: Instance): boolean
	return instance:IsA("ModuleScript") and instance.Name:match(constants.STORYBOOK_NAME_PATTERN)
end

return isStorybookModule
