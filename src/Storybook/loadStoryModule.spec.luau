local JestGlobals = require("@pkg/JestGlobals")
local ModuleLoader = require("@pkg/ModuleLoader")
local constants = require("@root/constants")
local loadStoryModule = require("./loadStoryModule")
local types = require("@root/Storybook/types")

local test = JestGlobals.test
local expect = JestGlobals.expect

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
	storyModule.Name = "Foo.story"
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

	expect(story.name).toEqual("Sample")
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

	expect(story).toBeDefined()
end)

test("use the name of the story module for the story name", function()
	local loader = ModuleLoader.new()
	local storyModule = createMockStoryModule([[
			return {
				story = function() end
			}
		]])
	storyModule.Name = "SampleName.story"

	local story = loadStoryModule(loader, storyModule, MOCK_PLAIN_STORYBOOK)

	expect(story.name).toEqual(storyModule.Name)
end)

test("pass the storybook's renderer to the story", function()
	local loader = ModuleLoader.new()
	local storyModule = createMockStoryModule([[
			return {
				story = function() end
			}
		]])

	local story, err = loadStoryModule(loader, storyModule, MOCK_REACT_STORYBOOK)

	expect(story).toBeDefined()
	expect(err).toBeNil()
	expect(story.react).toBeDefined()
	expect(story.reactRoblox).toBeDefined()

	story, err = loadStoryModule(loader, storyModule, MOCK_ROACT_STORYBOOK)

	expect(story).toBeDefined()
	expect(err).toBeNil()
	expect(story.roact).toBeDefined()
end)

test("generic failures for stories", function()
	local loader = ModuleLoader.new()
	local storyModule = createMockStoryModule([[
			return {
			}
		]])

	local story, err = loadStoryModule(loader, storyModule, MOCK_PLAIN_STORYBOOK)

	expect(story).toBeNil()
	expect(err).toBeDefined()
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

	expect(story).toBeNil()
	expect(err).toBeDefined()
end)
