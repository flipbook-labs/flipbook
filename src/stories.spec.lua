local CoreGui = game:GetService("CoreGui")

local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local isStoryModule = require("@root/Storybook/isStoryModule")
local mountStory = require("@root/Storybook/mountStory")

return function()
	for _, descendant in ipairs(script.Parent:GetDescendants()) do
		if isStoryModule(descendant) then
			it("should mount/unmount " .. descendant.Name, function()
				local story = require(descendant)
				story.react = React
				story.reactRoblox = ReactRoblox

				local cleanup
				expect(function()
					cleanup = mountStory(story, story.controls, CoreGui)
				end).to.never.throw()

				if cleanup then
					expect(cleanup).to.never.throw()
				end
			end)
		end
	end
end
