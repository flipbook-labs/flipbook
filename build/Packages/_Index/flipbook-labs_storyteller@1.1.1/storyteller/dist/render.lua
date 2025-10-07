local Sift = require(script.Parent.Parent.Sift)

local createRendererForStory = require(script.Parent.createRendererForStory)
local types = require(script.Parent.types)

type LoadedStory<T> = types.LoadedStory<T>
type StoryControls = types.StoryControls
type StoryProps = types.StoryProps
type StoryRenderer<T> = types.StoryRenderer<T>
type RenderLifecycle = types.RenderLifecycle

local function collapseControls(controls: StoryControls): StoryControls
	return Sift.Dictionary.map(controls, function(control)
		-- Array values are collapsed to their first element to be passed off to
		-- the story as props
		if Sift.List.is(control) then
			return control[1]
		else
			return control
		end
	end)
end

--[=[
	Render a Story to an [Instance] in the [DataModel].

	After discovering, validating, and loading Story modules, rendering them is
	the final step to getting stories visually presented to the user.

	This function handles the lifecycle of mounting, updating, and unmounting
	the Story. On each update, controls can be passed down to the story for
	live-reloading from user interaction.

	**Usage:**

	```lua
	local ModuleLoader = require("@pkg/ModuleLoader")
	local Storyteller = require("@pkg/Storyteller")

	-- At least one `.storybook` module must be present
	local storybookModules = Storyteller.findStorybookModules(game)
	assert(#storybookModules > 0, "no Storybook modules found")

	local storybook
	pcall(function()
		storybook = Storyteller.loadStorybookModule(storybookModules[1])
	end)

	if storybook then
		-- At least one `.story` module must be a descendant of the Instances in
		-- a Storybook's `storyRoots` array
		local storyModules = Storyteller.findStoryModulesForStorybook(storybook)
		assert(#storyModules > 0, "no Story modules found")

		local story
		pcall(function()
			story = Storyteller.loadStoryModule(storyModules[1], storybook)
		end)

		if story then
			-- Finally, render the story to a container of your choosing
			local lifecycle = Storyteller.render(container, story)

			print(container:GetChildren())

			lifecycle.unmount()

			print(container:GetChildren())
		end
	end
	```

	@tag Rendering
	@within Storyteller
]=]
local function render<T>(container: Instance, story: LoadedStory<T>): RenderLifecycle
	local renderer = createRendererForStory(story)

	local prevProps: StoryProps?

	local function renderOnce(controls: StoryControls?)
		local props: StoryProps = Sift.Dictionary.join(story.props or {}, {
			container = container,
			story = story,
			theme = "Dark", -- TODO: Support theme changing
		})

		props.controls = Sift.Dictionary.join(
			if story.controls then collapseControls(story.controls) else nil,
			if controls then controls else nil
		)

		if renderer.transformProps then
			props = renderer.transformProps(props, prevProps)
		end

		if not renderer.shouldUpdate or renderer.shouldUpdate(props, prevProps) then
			renderer.mount(container, story, props)
		end

		prevProps = props
	end

	local function update(newControls: StoryControls?)
		if renderer.update then
			local props = Sift.Dictionary.join(prevProps, {
				controls = if newControls then collapseControls(newControls) else nil,
			})

			renderer.update(props, prevProps)
		else
			renderOnce(newControls)
		end
	end

	local function unmount()
		if renderer.unmount then
			renderer.unmount()
		end
		container:ClearAllChildren()
	end

	renderOnce()

	return {
		update = update,
		unmount = unmount,
	}
end

return render
