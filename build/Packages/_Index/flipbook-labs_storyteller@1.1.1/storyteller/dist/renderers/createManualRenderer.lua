local types = require(script.Parent.Parent.types)

type StoryProps = types.StoryProps
type LoadedStory<T> = types.LoadedStory<T>
type StoryRenderer<T> = types.StoryRenderer<T>

type CleanupFn = () -> ()
type ManualStory = Instance | ((props: StoryProps) -> CleanupFn?)

local function createManualRenderer(): StoryRenderer<ManualStory>
	local currentContainer
	local currentStory
	local cleanup: (() -> ())?

	local function mount(container: Instance, story: LoadedStory<ManualStory>, props: StoryProps)
		currentContainer = container
		currentStory = story

		local result

		if typeof(story.story) == "Instance" then
			result = story.story
		elseif typeof(story.story) == "function" then
			if debug.info(story.story, "a") >= 2 then
				result = (story :: any).story(container, props)
			else
				result = (story :: any).story(props)
			end
		end

		if typeof(result) == "function" then
			cleanup = result
		elseif typeof(result) == "Instance" then
			if not result.Parent then
				result.Parent = container
			end
		end
	end

	local function unmount()
		if cleanup then
			cleanup()
			cleanup = nil
		end

		currentContainer:ClearAllChildren()
	end

	local function update(props)
		unmount()
		mount(currentContainer, currentStory, props)
	end

	return {
		mount = mount,
		update = update,
		unmount = unmount,
	}
end

return createManualRenderer
