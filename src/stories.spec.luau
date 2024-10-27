local CoreGui = game:GetService("CoreGui")

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Sift = require("@pkg/Sift")
local Storyteller = require("@pkg/Storyteller")

local expect = JestGlobals.expect
local test = JestGlobals.test
local testEach = test.each :: any

testEach({
	Storyteller.findStoryModules(script.Parent),
})("mount/unmount %s", function(storyModule)
	local story = (require :: any)(storyModule)

	if typeof(story) == "function" then
		story = {
			name = storyModule.Name,
			story = story,
		}
	end

	if story.packages then
		story.packages = Sift.Dictionary.join(story.packages or {}, {
			React = React,
			ReactRoblox = ReactRoblox,
		})
	end

	local renderer = Storyteller.createRendererForStory(story)
	local lifecycle

	expect(function()
		lifecycle = Storyteller.render(renderer, CoreGui, story, story.controls)
	end).never.toThrow()

	expect(lifecycle.unmount).never.toThrow()
end)
