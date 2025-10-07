local React = require(script.Parent.Parent.Parent.React)

local loadStoryModule = require(script.Parent.Parent.loadStoryModule)
local types = require(script.Parent.Parent.types)
--[=[
	This hook triggers a rerender when the Story module or any of its required
	modules change. For example, updating the `story` property or updating a
	React component’s source will trigger useStory to rerender with the new
	content.

	:::info
	In the future version hooks may be migrated to a new package to remove the React dependency from Storyteller.
	:::

	Usage:

	```lua
	local React = require("@pkg/React")
	local Storyteller = require("@pkg/Storyteller")

	local useEffect = React.useEffect
	local useRef = React.useRef
	local e = React.createElement

	local function StoryView(props: {
		parent: Instance,
		storyModule: ModuleScript,
		storybook: Storybook,
	})
		local ref = useRef(nil :: Frame?)

		local story = Storyteller.useStory(props.storyModule, props.storybook)

		useEffect(function()
			if ref.current then
				local renderer = Storyteller.createRendererForStory(story)
				Storyteller.render(renderer, ref.current, story)
			end
		end, { story })

		return e("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ref = ref,
		})
	end

	return StoryView
	```

	@tag React
	@tag Story
	@within Storyteller
]=]

local function useStory(module: ModuleScript, storybook: types.LoadedStorybook): (types.LoadedStory<unknown>?, string?)
	local story, setStory = React.useState(nil :: types.LoadedStory<unknown>?)
	local err, setErr = React.useState(nil :: string?)

	React.useEffect(function()
		local function loadStory()
			local newStory
			local success, result = pcall(function()
				newStory = loadStoryModule(module, storybook)
			end)

			setStory(if success then newStory else nil)
			setErr(if success then nil else result)
		end

		local connections: { RBXScriptConnection } = {}

		table.insert(
			connections,
			storybook.loader.loadedModuleChanged:Connect(function(other)
				if other == module then
					loadStory()
				end
			end)
		)

		table.insert(connections, module:GetPropertyChangedSignal("Source"):Connect(loadStory))

		loadStory()

		return function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end
	end, { module, storybook } :: { unknown })

	return story, err
end

return useStory
