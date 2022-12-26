local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(script.Parent.Packages.Roact)
local isStoryModule = require(script.Parent.Story.isStoryModule)
local getStoryElement = require(script.Parent.Story.getStoryElement)

return function()
	Roact.setGlobalConfig({
		propValidation = true,
		elementTracing = true,
	})

	for _, descendant in ipairs(script.Parent.Components:GetDescendants()) do
		if isStoryModule(descendant) then
			it("should mount/unmount " .. descendant.Name, function()
				local story = require(descendant)
				local element = getStoryElement(story, story.controls)

				local handle
				expect(function()
					handle = Roact.mount(element, ReplicatedStorage)
				end).to.never.throw()

				expect(function()
					Roact.unmount(handle)
				end).to.never.throw()
			end)
		end
	end
end
