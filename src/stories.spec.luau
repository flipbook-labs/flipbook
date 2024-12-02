local CoreGui = game:GetService("CoreGui")

local JestGlobals = require("@pkg/jest-globals")

local ModuleLoader = require("@pkg/module-loader")

local React = require("@pkg/react")
local ReactRoblox = require("@pkg/react-roblox")
local Sift = require("@pkg/sift")
local Storyteller = require("@pkg/storyteller")

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local describeEach = describe.each :: any
local expect = JestGlobals.expect
local test = JestGlobals.test

local container

beforeEach(function()
	container = Instance.new("Folder")
	container.Parent = CoreGui
end)

afterEach(function()
	container:Destroy()
end)

describeEach({
	Storyteller.findStorybookModules(script.Parent),
})("%s", function(storybookModule)
	-- FIXME: This is needed to get around a bug with React renders. I'm hoping
	-- to keep this for now, but in the future this should really be a
	-- ModuleLoader instance
	local mockModuleLoader = (
		{
			require = function(_self, path)
				return (require :: any)(path)
			end,
		} :: any
	) :: ModuleLoader.ModuleLoader

	local storybook = Storyteller.loadStorybookModule(mockModuleLoader, storybookModule)

	describeEach({
		Storyteller.findStoryModulesForStorybook(storybook),
	})("%s", function(storyModule)
		test("basic mount/unmount lifecycle", function()
			local story = Storyteller.loadStoryModule(mockModuleLoader, storyModule, storybook)

			if story.packages then
				story.packages = Sift.Dictionary.join(story.packages, {
					React = React,
					ReactRoblox = ReactRoblox,
				})
			end

			local lifecycle = Storyteller.render(container, story)

			expect(#container:GetChildren()).toBe(1)

			lifecycle.unmount()

			expect(#container:GetChildren()).toBe(0)
		end)
	end)
end)
