local CoreGui = game:GetService("CoreGui")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local ReactRoblox = require("@pkg/ReactRoblox")
local Storyteller = require("@pkg/Storyteller")

local StoryControlsContext = require("@root/StoryControls/StoryControlsContext")
local StoryError = require("@root/Storybook/StoryError")
local StoryStore = require("@root/Storybook/StoryStore")
local types = require("@root/Storybook/types")

local e = React.createElement
local useState = React.useState
local useEffect = React.useEffect
local useSignalState = ReactCharm.useSignalState

type LoadedStory = Storyteller.LoadedStory<unknown>

export type Props = {
	story: LoadedStory,

	extraProps: types.ExtraStoryProps?,
	LayoutOrder: number?,
}

local function StoryPreview(props: Props): React.Node
	local storyStore = useSignalState(StoryStore.get)
	local isMountedInViewport = useSignalState(storyStore.getIsMountedInViewport)
	local zoom = useSignalState(storyStore.getZoom)
	local storyControls = StoryControlsContext.useStoryControls()
	local controls = useSignalState(storyControls.getControls)
	local err: string?, setErr = useState(nil :: string?)

	useEffect(function()
		setErr(nil)
	end, { props.story })

	if err then
		return e(StoryError, {
			LayoutOrder = props.LayoutOrder,
			errorMessage = err,
		})
	end

	if isMountedInViewport then
		return ReactRoblox.createPortal({
			Story = e("ScreenGui", {
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				ref = storyStore.storyContainerRef,
			}, {
				StoryContainer = e(Storyteller.StoryContainer, {
					story = props.story,
					controls = controls,
					extraProps = props.extraProps,
					onError = setErr,
				}),
			}),
		}, CoreGui)
	end

	return e(Foundation.ScrollView, {
		tag = "size-full",
		scroll = {
			ScrollingDirection = Enum.ScrollingDirection.XY,
			AutomaticCanvasSize = Enum.AutomaticSize.XY,
			CanvasSize = UDim2.fromScale(0, 0),
		},
		layout = {
			FillDirection = Enum.FillDirection.Vertical,
		},
		LayoutOrder = props.LayoutOrder,
		ref = storyStore.storyContainerRef,
	}, {
		Scale = e("UIScale", {
			Scale = 1 + zoom,
		}),

		StoryContainer = e(Storyteller.StoryContainer, {
			story = props.story,
			controls = controls,
			extraProps = props.extraProps,
			onError = setErr,
		}),
	})
end

return StoryPreview
