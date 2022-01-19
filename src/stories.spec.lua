local CoreGui = game:GetService("CoreGui")

local Roact = require(script.Parent.Packages.Roact)
local isStory = require(script.Parent.Modules.isStory)

return function()
	Roact.setGlobalConfig({
		propValidation = true,
		elementTracing = true,
	})

	for _, descendant in ipairs(script.Parent:GetDescendants()) do
		if isStory(descendant) then
			it("should mount/unmount " .. descendant:GetFullName(), function()
				local story = require(descendant)

				local root
				if typeof(story.story) == "function" then
					root = Roact.createElement(story.story, {
						controls = story.controls or {},
					})
				else
					root = story.story
				end

				local handle
				expect(function()
					handle = Roact.mount(root, CoreGui)
				end).to.never.throw()

				expect(function()
					Roact.unmount(handle)
				end).to.never.throw()
			end)
		end
	end
end
