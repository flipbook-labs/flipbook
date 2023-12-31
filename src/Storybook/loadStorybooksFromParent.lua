local flipbook = script:FindFirstAncestor("flipbook")

local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local findStorybookModules = require(flipbook.Storybook.findStorybookModules)
local loadStorybookModule = require(flipbook.Storybook.loadStorybookModule)
local types = require(flipbook.Storybook.types)

type Storybook = types.Storybook
type ModuleLoader = typeof(ModuleLoader.new())

local function loadStorybooks(parent: Instance, loader: ModuleLoader): ({ Storybook }, { string })
	local storybooks = {}
	local errors = {}

	for _, storybookModule in findStorybookModules(parent) do
		local storybook, err = loadStorybookModule(storybookModule, loader)

		if storybook then
			table.insert(storybooks, storybook)
		elseif err then
			table.insert(errors, err)
		end
	end

	return storybooks, errors
end

return loadStorybooks
