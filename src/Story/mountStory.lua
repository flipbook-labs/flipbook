local types = require(script.Parent.Parent.types)
local getStoryElement = require(script.Parent.getStoryElement)

local function mountFunctionalStory(story: types.FunctionalStory, props: types.StoryProps, parent: GuiObject)
	local result
	xpcall(function()
		result = story.story(parent, props)
	end, debug.traceback)

	return function()
		if typeof(result) == "Instance" then
			result:Destroy()
		end
	end
end

local function mountRoactStory(story: types.RoactStory, props: types.StoryProps, parent: GuiObject)
	local element = getStoryElement(story, props)

	local handle
	xpcall(function()
		handle = story.roact.mount(element, parent, story.name)
	end, debug.traceback)

	return function()
		if handle then
			story.roact.unmount(handle)
		end
	end
end

local function mountHorcekatStory(story: types.HoarcekatStory, props: types.StoryProps, parent: GuiObject)
	local cleanup: (() -> ()?) = story(parent, props)

	xpcall(function()
		cleanup = story(parent, props)
	end, debug.traceback)

	return function()
		if cleanup then
			cleanup()
		end
	end
end

local function mountStory(story: types.Story, controls: types.Controls, parent: GuiObject)
	local props: types.StoryProps = {
		controls = controls,
	}

	if types.RoactStory(story) then
		return mountRoactStory(story :: types.RoactStory, props, parent)
	elseif types.FunctionalStory(story) then
		return mountFunctionalStory(story :: types.FunctionalStory, props, parent)
	elseif types.HoarcekatStory(story) then
		return mountHorcekatStory(story :: types.HoarcekatStory, props, parent)
	else
		return nil
	end
end

return mountStory
