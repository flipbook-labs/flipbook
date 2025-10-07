local types = require(script.Parent.Parent.types)

type StoryRenderer<T> = types.StoryRenderer<T>
type LoadedStory<T> = types.LoadedStory<T>
type StoryProps = types.StoryProps

type Packages = {
	React: any,
	ReactRoblox: any,
}

local function isReactElement(maybeElement: any): boolean
	if typeof(maybeElement) == "table" then
		return maybeElement["$$typeof"] and maybeElement.props and maybeElement.type
	end
	return false
end

local function createReactRenderer<T>(packages: Packages): StoryRenderer<T>
	local React = packages.React
	local ReactRoblox = packages.ReactRoblox

	local root
	local currentStory

	local function reactRender(story: types.LoadedStory<unknown>, props: StoryProps)
		local mapStory = if story.storybook then story.storybook.mapStory else nil
		local mapDefinition = if story.storybook then story.storybook.mapDefinition else nil

		if mapDefinition then
			story = mapDefinition(story)
		end

		local element
		if isReactElement(story.story) then
			element = story.story
		else
			element = React.createElement(story.story, props)
		end

		if mapStory then
			element = React.createElement(mapStory(story.story), props, element)
		end

		currentStory = story
		root:render(element)
	end

	local function mount(container: Instance, story: LoadedStory<T>, props: StoryProps)
		root = ReactRoblox.createRoot(container)
		reactRender(story, props)
	end

	local function update(props: StoryProps)
		if currentStory then
			reactRender(currentStory, props)
		end
	end

	local function unmount()
		root:unmount()
	end

	return {
		mount = mount,
		update = update,
		unmount = unmount,
	}
end

return createReactRenderer
