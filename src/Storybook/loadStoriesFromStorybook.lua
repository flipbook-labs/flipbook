local flipbook = script:FindFirstAncestor("flipbook")

local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local types = require(flipbook.Storybook.types)
local findStoryModules = require(flipbook.Storybook.findStoryModules)
local loadStoryModule = require(flipbook.Storybook.loadStoryModule)

type ModuleLoader = typeof(ModuleLoader.new())
type Story = types.Story
type Storybook = types.Storybook

local function loadStoriesFromStorybook(storybook: Storybook, loader: ModuleLoader): { Story }
	local stories = {}
	local errors = {}

	for _, storyRoot in storybook.storyRoots do
		for _, storyModule in findStoryModules(storyRoot) do
			local story, err = loadStoryModule(loader, storyModule, storybook)

			if story then
				table.insert(stories, story)
			elseif err then
				table.insert(errors, err)
			end
		end
	end
	return stories, errors
end

return loadStoriesFromStorybook
