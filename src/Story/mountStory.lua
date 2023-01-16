local types = require(script.Parent.Parent.types)

local function mountFunctionalStory(story: types.FunctionalStory, props: types.StoryProps, parent: GuiObject)
	local cleanup: (() -> ())?

	xpcall(function()
		cleanup = story.story(parent, props)
	end, debug.traceback)

	return function()
		if typeof(cleanup) == "function" then
			cleanup()
		end

		-- TODO: First find a way to ensure the UIScale in `parent` won't be
		-- destroyed by calling this
		-- parent:ClearAllChildren()
	end
end

local function mountRoactStory(story: types.RoactStory, props: types.StoryProps, parent: GuiObject)
	local Roact = story.roact

	local element
	if typeof(story.story) == "function" then
		local success, result = pcall(function()
			return Roact.createElement(story.story, props)
		end)

		element = if success then result else nil
	else
		element = story.story
	end

	local handle
	xpcall(function()
		handle = Roact.mount(element, parent, story.name)
	end, debug.traceback)

	return function()
		if handle then
			Roact.unmount(handle)
		end
	end
end

local function mountReactStory(story: types.ReactStory, props: types.StoryProps, parent: GuiObject)
	local React = story.react
	local ReactRoblox = story.reactRoblox

	local root = ReactRoblox.createRoot(parent)

	local element
	if typeof(story.story) == "function" then
		xpcall(function()
			element = React.createElement(story.story, props)
		end, debug.traceback)
	else
		element = story.story
	end

	xpcall(function()
		root:render(element)
	end, debug.traceback)

	return function()
		root:unmount()
	end
end

local function mountStory(story: types.Story, controls: types.Controls, parent: GuiObject): (() -> ())?
	local props: types.StoryProps = {
		controls = controls,
	}

	if story.roact then
		return mountRoactStory(story :: types.RoactStory, props, parent)
	elseif story.react then
		return mountReactStory(story :: types.ReactStory, props, parent)
	elseif typeof(story.story) == "function" then
		return mountFunctionalStory(story :: types.FunctionalStory, props, parent)
	else
		return nil
	end
end

return mountStory
