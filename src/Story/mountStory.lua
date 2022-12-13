local flipbook = script:FindFirstAncestor("flipbook")

local enums = require(flipbook.enums)
local types = require(script.Parent.Parent.types)
local getStoryElement = require(script.Parent.getStoryElement)

local function mountStory(story: types.Story, parent: Instance)
	local handle

	if story.format == enums.Format.Default then
		local element = getStoryElement(story)

		xpcall(function()
			handle = story.roact.mount(element, parent, story.name)
		end, debug.traceback)
	elseif story.format == enums.Format.Hoarcekat and typeof(story.story) == "function" then
		xpcall(function()
			handle = story.story(parent :: any)
		end, debug.traceback)
	end

	return handle
end

return mountStory
