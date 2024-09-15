local CoreGui = game:GetService("CoreGui")

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local isStoryModule = require("@root/Storybook/isStoryModule")
local mountStory = require("@root/Storybook/mountStory")

local expect = JestGlobals.expect
local test = JestGlobals.test

local storyModules: { ModuleScript } = {}
for _, descendant in ipairs(script.Parent:GetDescendants()) do
	if isStoryModule(descendant) then
		table.insert(storyModules, descendant)
	end
end

for _, storyModule in storyModules do
	test(`mount/unmount {storyModule:GetFullName()}`, function()
		local story = (require :: any)(storyModule)
		if typeof(story) == "function" then
			story = {
				name = storyModule.Name,
				story = story,
			}
		end

		story.react = React
		story.reactRoblox = ReactRoblox

		local cleanup
		expect(function()
			cleanup = mountStory(story, story.controls, CoreGui)
		end).never.toThrow()

		if cleanup then
			expect(cleanup).never.toThrow()
		end
	end)
end
