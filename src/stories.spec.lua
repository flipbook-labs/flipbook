local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(script.Parent.Packages.Roact)
local isStoryModule = require(script.Parent.Story.isStoryModule)
local mountStory = require(script.Parent.Story.mountStory)

return function()
	Roact.setGlobalConfig({
		propValidation = true,
		elementTracing = true,
	})

	for _, descendant in ipairs(script.Parent.Components:GetDescendants()) do
		if isStoryModule(descendant) then
			it("should mount/unmount " .. descendant.Name, function()
				local story = require(descendant)

				local cleanup
				expect(function()
					cleanup = mountStory(story, story.controls, ReplicatedStorage)
				end).to.never.throw()

				if cleanup then
					expect(cleanup).to.never.throw()
				end
			end)
		end
	end
end
