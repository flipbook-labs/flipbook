local CoreGui = game:GetService("CoreGui")

local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Sift = require("@pkg/Sift")
local Storyteller = require("@pkg/Storyteller")

local ScrollingFrame = require("@root/Common/ScrollingFrame")
local StoryError = require("@root/Storybook/StoryError")
local usePrevious = require("@root/Common/usePrevious")

local e = React.createElement

local defaultProps = {
	isMountedInViewport = false,
	zoom = 0,
}

type LoadedStory = Storyteller.LoadedStory<unknown>

export type Props = {
	story: LoadedStory,
	controls: { [string]: any },

	isMountedInViewport: boolean?,
	layoutOrder: number?,
	zoom: number?,
	ref: any,
}

type InternalProps = Props & typeof(defaultProps)

local StoryPreview = React.forwardRef(function(providedProps: Props, ref: any)
	local props: InternalProps = Sift.Dictionary.merge(defaultProps, providedProps)
	local lifecycle = React.useRef(nil :: Storyteller.RenderLifecycle?)
	local err, setErr = React.useState(nil :: string?)
	local prevControls = usePrevious(props.controls)
	local prevStory = usePrevious(props.story)

	React.useEffect(function()
		setErr(nil)
	end, { props.story, ref })

	React.useEffect(function()
		if props.story == prevStory and props.controls ~= prevControls then
			local areControlsDifferent = prevControls and not Sift.Dictionary.equals(props.controls, prevControls)

			if lifecycle.current and areControlsDifferent then
				local success, result = xpcall(function()
					lifecycle.current.update(props.controls)
				end, debug.traceback)

				if not success then
					setErr(result)
				end
			end
		end
	end, { props.controls, prevControls, props.story, prevStory } :: { unknown })

	React.useEffect(function(): (() -> ())?
		if props.story and ref.current then
			local success, result = xpcall(function()
				lifecycle.current = Storyteller.render(ref.current, props.story)
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
	end, { props.story, props.isMountedInViewport } :: { unknown })

	if err then
		return e(StoryError, {
			layoutOrder = props.layoutOrder,
			err = err,
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
			return e(ScrollingFrame, {
				BackgroundTransparency = 1,
				LayoutOrder = props.layoutOrder,
				ScrollingDirection = Enum.ScrollingDirection.XY,
				AutomaticCanvasSize = Enum.AutomaticSize.XY,
				CanvasSize = UDim2.new(),
				Size = UDim2.fromScale(1, 1),
				ref = ref,
			}, {
				Scale = e("UIScale", {
					Scale = 1 + props.zoom,
				}),
			})
		end
	end
end)

return StoryPreview
