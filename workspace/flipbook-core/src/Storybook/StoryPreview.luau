local CoreGui = game:GetService("CoreGui")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local ReactRoblox = require("@pkg/ReactRoblox")
local Storyteller = require("@pkg/Storyteller")

local FlipbookStoreContext = require("@root/FlipbookStore/FlipbookStoreContext")
local StoryError = require("@root/Storybook/StoryError")
local types = require("@root/Storybook/types")
local useStoryControlValues = require("@root/StoryControls/useStoryControlValues")

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
	local flipbookStore = FlipbookStoreContext.use()
	local isMountedInViewport = useSignalState(flipbookStore.story.getIsMountedInViewport)
	local zoom = useSignalState(flipbookStore.story.getZoom)
	local controls = useStoryControlValues()
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
				ref = flipbookStore.story.setStoryContainer,
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
		ref = flipbookStore.story.setStoryContainer,
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
