local Llama = require(script.Parent.Parent.Packages.Llama)
local ModuleLoader = require(script.Parent.Parent.Packages.ModuleLoader)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useStory = require(script.Parent.Parent.Hooks.useStory)
local useStoryRenderer = require(script.Parent.Parent.Hooks.useStoryRenderer)
local useViewportParent = require(script.Parent.Parent.Hooks.useViewportParent)
local types = require(script.Parent.Parent.types)
local styles = require(script.Parent.Parent.styles)
local StoryMeta = require(script.Parent.StoryMeta)
local StoryError = require(script.Parent.StoryError)

type Props = {
	story: ModuleScript,
	loader: ModuleLoader.Class,
	storybook: types.Storybook,
}

local function StoryView(props: Props, hooks: any)
	local previewRef = Roact.createRef()
	local story, storyErr = useStory(hooks, props.story, props.storybook, props.loader)
	local viewport, isUsingViewport, toggleViewport = useViewportParent(hooks)
	local controls, setControls = hooks.useState({})

	local parent, setParent = hooks.useState(nil)
	hooks.useEffect(function()
		setParent(if isUsingViewport then viewport else previewRef:getValue())
	end, { setParent, isUsingViewport })

	local err = useStoryRenderer(hooks, story, controls, parent)

	if storyErr then
		err = storyErr
	end

	local onControlChanged = hooks.useCallback(function(key: string, newValue: any)
		setControls(function(prev)
			return Llama.Dictionary.join(prev, {
				[key] = newValue,
			})
		end)
	end, { setControls })

	hooks.useEffect(function()
		setControls(if story and story.controls then story.controls else {})
	end, { story, setControls })

	return Roact.createElement("ScrollingFrame", Llama.Dictionary.join(styles.ScrollingFrame, {}), {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Meta = story and Roact.createElement(StoryMeta, {
			layoutOrder = 1,
			story = story,
			storyModule = props.story,
			storyParent = parent,
			controls = controls,
			onControlChanged = onControlChanged,
			onViewportToggled = toggleViewport,
		}),

		Preview = Roact.createElement("Frame", {
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			[Roact.Ref] = previewRef,
		}, {
			MountedInViewport = isUsingViewport and Roact.createElement(
				"TextLabel",
				Llama.Dictionary.join(styles.TextLabel, {
					Text = "Story mounted in viewport...",
				})
			),

			Error = err and Roact.createElement(StoryError, {
				message = err,
			}),

			Padding = Roact.createElement("UIPadding", {
				PaddingTop = styles.LARGE_PADDING,
				PaddingRight = styles.LARGE_PADDING,
				PaddingBottom = styles.LARGE_PADDING,
				PaddingLeft = styles.LARGE_PADDING,
			}),
		}),
	})
end

return RoactHooks.new(Roact)(StoryView)
