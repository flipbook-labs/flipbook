local CoreGui = game:GetService("CoreGui")

local flipbook = script:FindFirstAncestor("flipbook")

local JestGlobals = require(flipbook.Packages.JestGlobals)
local React = require(flipbook.Packages.React)
local ReactRoblox = require(flipbook.Packages.ReactRoblox)
local isStoryModule = require(flipbook.Storybook.isStoryModule)
local mountStory = require(flipbook.Storybook.mountStory)

local expect = JestGlobals.expect
local test = JestGlobals.test

local storyModules: { ModuleScript } = {}
for _, descendant in ipairs(flipbook:GetDescendants()) do
	if isStoryModule(descendant) then
		table.insert(storyModules, descendant)
	end
end

test.each(storyModules)("mount/unmount %s", function(storyModule: ModuleScript)
	local story = require(storyModule)
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
