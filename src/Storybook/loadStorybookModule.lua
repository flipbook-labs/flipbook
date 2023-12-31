local flipbook = script:FindFirstAncestor("flipbook")

local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local types = require(flipbook.Storybook.types)
local constants = require(flipbook.constants)

type ModuleLoader = typeof(ModuleLoader.new())
type Storybook = types.Storybook

local function loadStorybook(storybookModule: ModuleScript, loader: ModuleLoader): (Storybook?, string?)
	local err
	local success, result = pcall(function()
		return loader:require(storybookModule)
	end)

	if success then
		local isStorybook, message = types.Storybook(result)

		if isStorybook then
			result.name = if result.name
				then result.name
				else storybookModule.Name:gsub(constants.STORYBOOK_NAME_PATTERN, "")

			return result, nil
		else
			err = message
		end
	else
		err = result
	end

	return nil, `Failed to load storybook {storybookModule:GetFullName()}. Error: {err}`
end

return loadStorybook
