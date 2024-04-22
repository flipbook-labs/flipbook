local flipbook = script:FindFirstAncestor("flipbook")

local JestGlobals = require(flipbook.Packages.JestGlobals)
local ModuleLoader = require(flipbook.Packages.ModuleLoader)
local constants = require(flipbook.constants)
local loadStoryModule = require(script.Parent.loadStoryModule)
local types = require(flipbook.Storybook.types)

local expect = JestGlobals.expect
local test = JestGlobals.test

local MOCK_ROACT = {
	createElement = function() end,
	mount = function() end,
	unmount = function() end,
}

local MOCK_REACT = {
	createElement = function() end,
}

local MOCK_REACT_ROBLOX = {
	createRoot = function() end,
}

local MOCK_PLAIN_STORYBOOK: types.Storybook = {
	storyRoots = {},
}

local MOCK_ROACT_STORYBOOK: types.Storybook = {
	storyRoots = {},
	roact = MOCK_ROACT,
}

local MOCK_REACT_STORYBOOK: types.Storybook = {
	storyRoots = {},
	react = MOCK_REACT,
	reactRoblox = MOCK_REACT_ROBLOX,
}

local function createMockStoryModule(source: string): ModuleScript
	local storyModule = Instance.new("ModuleScript")
	storyModule.Name = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then "Foo.stories" else "Foo.story"
	storyModule.Source = source

	return storyModule
end

test("load a story module as a table", function()
	local loader = ModuleLoader.new()
	local storyModule = createMockStoryModule([[
			return {
				name = "Sample",
				story = function() end
			}
		]])

	local story = loadStoryModule(loader, storyModule, MOCK_PLAIN_STORYBOOK)

	expect(story.name).to.equal("Sample")
end)

test("handle Hoarcekat stories", function()
	local loader = ModuleLoader.new()
	local storyModule = createMockStoryModule([[
			return function(target)
				local gui = Instance.new("TextLabel")
				gui.Parent = target

				return function()
					gui:Destroy()
				end
			end
		]])

	local story = loadStoryModule(loader, storyModule, MOCK_PLAIN_STORYBOOK)

	expect(story).to.be.ok()
end)

test("use the name of the story module for the story name", function()
	local loader = ModuleLoader.new()
	local storyModule = createMockStoryModule([[
			return {
				story = function() end
			}
		]])
	storyModule.Name = if constants.FLAG_ENABLE_COMPONENT_STORY_FORMAT then "SampleName.stories" else "SampleName.story"

	local story = loadStoryModule(loader, storyModule, MOCK_PLAIN_STORYBOOK)

	expect(story.name).to.equal(storyModule.Name)
end)

test("pass the storybook's renderer to the story", function()
	local loader = ModuleLoader.new()
	local storyModule = createMockStoryModule([[
			return {
				story = function() end
			}
		]])

	local story, err = loadStoryModule(loader, storyModule, MOCK_REACT_STORYBOOK)

	expect(story).to.be.ok()
	expect(err).never.to.be.ok()
	expect(story.react).to.be.ok()
	expect(story.reactRoblox).to.be.ok()

	story, err = loadStoryModule(loader, storyModule, MOCK_ROACT_STORYBOOK)

	expect(story).to.be.ok()
	expect(err).never.to.be.ok()
	expect(story.roact).to.be.ok()
end)

test("generic failures for stories", function()
	local loader = ModuleLoader.new()
	local storyModule = createMockStoryModule([[
			return {
			}
		]])

	local story, err = loadStoryModule(loader, storyModule, MOCK_PLAIN_STORYBOOK)

	expect(story).never.to.be.ok()
	expect(err).to.be.ok()
end)

test("malformed stories", function()
	local loader = ModuleLoader.new()
	local storyModule = createMockStoryModule([[
			return {
				name = false,
				story = "should be a function"
			}
		]])

	local story, err = loadStoryModule(loader, storyModule, MOCK_PLAIN_STORYBOOK)

	expect(story).never.to.be.ok()
	expect(err).to.be.ok()
end)
