local CoreGui = game:GetService("CoreGui")

local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local ReactRoblox = require(flipbook.Packages.ReactRoblox)
local isStoryModule = require(flipbook.Story.isStoryModule)
local getStoryElement = require(flipbook.Story.getStoryElement)

return function()
	React.setGlobalConfig({
		propValidation = true,
		elementTracing = true,
	})

	local container = Instance.new("ScreenGui")
	container.Parent = CoreGui

	local root = ReactRoblox.createRoot(container)

	for _, descendant in ipairs(flipbook.Components:GetDescendants()) do
		if isStoryModule(descendant) then
			it("should mount/unmount " .. descendant.Name, function()
				local story = require(descendant)
				local element = getStoryElement(story, story.controls)

				expect(function()
					root:render(element)
				end).to.never.throw()

				expect(function()
					root:unmount()
				end).to.never.throw()
			end)
		end
	end
end
