local CoreGui = game:GetService("CoreGui")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Sift = require("@pkg/Sift")
local Storyteller = require("@pkg/Storyteller")

local StoryError = require("@root/Storybook/StoryError")
local usePrevious = require("@root/Common/usePrevious")
local useThemeName = require("@root/Common/useThemeName")

local e = React.createElement

local defaultProps = {
	isMountedInViewport = false,
	zoom = 0,
}

type LoadedStory = Storyteller.LoadedStory<unknown>

export type Props = {
	LayoutOrder: number?,
	controls: { [string]: any },
	isMountedInViewport: boolean?,
	ref: any,
	story: LoadedStory,
	zoom: number?,
}

type InternalProps = Props & typeof(defaultProps)

local StoryPreview = React.forwardRef(function(providedProps: Props, ref: any)
	local props: InternalProps = Sift.Dictionary.merge(defaultProps, providedProps)

	local lifecycle = React.useRef(nil :: Storyteller.RenderLifecycle?)
	local err, setErr = React.useState(nil :: string?)
	local prevControls = usePrevious(props.controls)
	local prevStory = usePrevious(props.story)
	local theme = useThemeName()

	React.useEffect(function()
		setErr(nil)
	end, { props.story, ref })

	local extraProps: Storyteller.ExtraStoryProps = React.useMemo(function()
		return {
			theme = theme :: useThemeName.ThemeName,
		}
	end, { theme } :: { unknown })

	React.useEffect(function()
		if props.story == prevStory and props.controls ~= prevControls then
			local areControlsDifferent = prevControls and not Sift.Dictionary.equals(props.controls, prevControls)

			if lifecycle.current and areControlsDifferent then
				local success, result = xpcall(function()
					lifecycle.current.update(props.controls, extraProps)
				end, debug.traceback)

				if not success then
					setErr(result)
				end
			end
		end
	end, { props.controls, prevControls, props.story, prevStory, extraProps } :: { unknown })

	React.useEffect(function(): (() -> ())?
		-- TODO: When storyProps changes we don't want the effect body to run,
		-- but we do for other dependencies. What's a good way to handle that?
		if props.story and ref.current then
			local success, result = xpcall(function()
				lifecycle.current = Storyteller.render(ref.current, props.story, extraProps)
			end, debug.traceback)

			if not success then
				setErr(result)
			end
		end

		return function()
			if lifecycle.current then
				lifecycle.current.unmount()
				lifecycle.current = nil
			end
		end
	end, { props.story, props.isMountedInViewport, storyProps } :: { unknown })

	if err then
		return e(StoryError, {
			LayoutOrder = props.LayoutOrder,
			errorMessage = err,
		})
	else
		if props.isMountedInViewport then
			return ReactRoblox.createPortal({
				Story = e("ScreenGui", {
					ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
					ref = ref,
				}),
			}, CoreGui)
		else
			return e(Foundation.ScrollView, {
				tag = "size-full",
				scroll = {
					ScrollingDirection = Enum.ScrollingDirection.XY,
					AutomaticCanvasSize = Enum.AutomaticSize.XY,
					CanvasSize = UDim2.new(0, 0),
				},
				LayoutOrder = props.LayoutOrder,
				scrollingFrameRef = ref,
			}, {
				Scale = e("UIScale", {
					Scale = 1 + props.zoom,
				}),
			})
		end
	end
end)

return StoryPreview
