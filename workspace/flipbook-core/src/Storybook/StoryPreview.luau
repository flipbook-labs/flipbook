local CoreGui = game:GetService("CoreGui")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local ReactRoblox = require("@pkg/ReactRoblox")
local Storyteller = require("@pkg/Storyteller")

local ErrorBoundary = require("@root/Common/ErrorBoundary")
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
	local err: string?, setErr = useState<<string?>>(nil)

	useEffect(function()
		setErr(nil)
	end, { props.story })

	if err then
		return e(StoryError, {
			LayoutOrder = props.LayoutOrder,
			errorMessage = err,
		})
	end

	--[[
		Storyteller reports most Story errors through `onError`, but an error
		that escapes the Story would otherwise unmount all of Flipbook. The
		boundary shows it like any other Story error, and clears once a
		different Story is selected.
	]]
	local storyContainer = e(ErrorBoundary, {
		resetKey = props.story,
		fallback = function(problem: string)
			return e(StoryError, {
				errorMessage = problem,
			})
		end,
	}, {
		StoryContainer = e(Storyteller.StoryContainer, {
			story = props.story,
			controls = controls,
			extraProps = props.extraProps,
			onError = setErr,
		}),
	})

	if isMountedInViewport then
		return ReactRoblox.createPortal({
			Story = e("ScreenGui", {
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				ref = flipbookStore.story.setStoryContainer,
			}, {
				StoryContainer = storyContainer,
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

		StoryContainer = storyContainer,
	})
end

return StoryPreview
