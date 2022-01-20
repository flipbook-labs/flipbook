local CoreGui = game:GetService("CoreGui")

local Roact = require(script.Parent.Packages.Roact)
local isStoryModule = require(script.Parent.Modules.isStoryModule)

return function()
	Roact.setGlobalConfig({
		propValidation = true,
		elementTracing = true,
	})

	for _, descendant in ipairs(script.Parent:GetDescendants()) do
		if isStoryModule(descendant) then
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
