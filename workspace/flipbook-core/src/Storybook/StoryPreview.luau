local CoreGui = game:GetService("CoreGui")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Storyteller = require("@pkg/Storyteller")

local StoryActionsContext = require("@root/Storybook/StoryActionsContext")
local StoryError = require("@root/Storybook/StoryError")

local e = React.createElement
local useState = React.useState
local useEffect = React.useEffect

type LoadedStory = Storyteller.LoadedStory<unknown>

export type Props = {
	story: LoadedStory,

	controls: Storyteller.StoryControls?,
	extraProps: Storyteller.StoryProps?,
	LayoutOrder: number?,
}

local function StoryPreview(props: Props): React.Node
	local storyActions = StoryActionsContext.useStoryActions()
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

	if storyActions.isMountedInViewport then
		return ReactRoblox.createPortal({
			Story = e("ScreenGui", {
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				ref = storyActions.storyContainerRef,
			}, {
				StoryContainer = e(Storyteller.StoryContainer, {
					story = props.story,
					controls = props.controls,
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
			CanvasSize = UDim2.new(0, 0),
		},
		LayoutOrder = props.LayoutOrder,
		ref = storyActions.storyContainerRef,
	}, {
		Scale = e("UIScale", {
			Scale = 1 + storyActions.zoom.value,
		}),

		StoryContainer = e(Storyteller.StoryContainer, {
			story = props.story,
			controls = props.controls,
			extraProps = props.extraProps,
			onError = setErr,
		}),
	})
end

return StoryPreview
