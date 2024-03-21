local types = require("@root/Storybook/types")

local function mountFunctionalStory(story: types.FunctionalStory, props: types.StoryProps, parent: GuiObject)
	local cleanup = story.story(parent, props)

	return function()
		if typeof(cleanup) == "function" then
			cleanup()
		end
	end
end

local function mountRoactStory(story: types.RoactStory, props: types.StoryProps, parent: GuiObject)
	local Roact = story.roact

	local element
	if typeof(story.story) == "function" then
		element = Roact.createElement(story.story, props)
	else
		element = story.story
	end

	local handle = Roact.mount(element, parent, story.name)

	return function()
		Roact.unmount(handle)
	end
end

local function mountReactStory(story: types.ReactStory, props: types.StoryProps, parent: GuiObject)
	local React = story.react
	local ReactRoblox = story.reactRoblox

	local root = ReactRoblox.createRoot(parent)

	local element
	if typeof(story.story) == "function" then
		element = React.createElement(story.story, props)
	else
		element = story.story
	end

	root:render(element)

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
	elseif story.react and story.reactRoblox then
		return mountReactStory(story :: types.ReactStory, props, parent)
	elseif typeof(story.story) == "function" then
		return mountFunctionalStory(story :: types.FunctionalStory, props, parent)
	else
		return nil
	end
end

return mountStory
