local CoreGui = game:GetService("CoreGui")

local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local ReactRoblox = require(flipbook.Packages.ReactRoblox)
local isStoryModule = require(flipbook.Storybook.isStoryModule)
local mountStory = require(flipbook.Storybook.mountStory)

return function()
	for _, descendant in ipairs(flipbook:GetDescendants()) do
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
