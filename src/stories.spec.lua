local CoreGui = game:GetService("CoreGui")

local flipbook = script:FindFirstAncestor("flipbook")

local React = require(script.Parent.Packages.React)
local isStoryModule = require(script.Parent.Story.isStoryModule)
local mountStory = require(script.Parent.Story.mountStory)

return function()
	React.setGlobalConfig({
		propValidation = true,
		elementTracing = true,
	})

	for _, descendant in ipairs(flipbook.Components:GetDescendants()) do
		if isStoryModule(descendant) then
			it("should mount/unmount " .. descendant.Name, function()
				local story = require(descendant)

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
