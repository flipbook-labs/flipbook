local CoreGui = game:GetService("CoreGui")

local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local ScrollingFrame = require("@root/Common/ScrollingFrame")
local Sift = require("@pkg/Sift")
local StoryError = require("@root/Storybook/StoryError")
local mountStory = require("@root/Storybook/mountStory")
local types = require("@root/Storybook/types")

local e = React.createElement

local defaultProps = {
	isMountedInViewport = false,
	zoom = 0,
}

export type Props = {
	layoutOrder: number,
	story: types.Story,
	ref: any,
	controls: { [string]: any },
	storyModule: ModuleScript,
}

type InternalProps = Props & typeof(defaultProps)

local StoryPreview = React.forwardRef(function(providedProps: Props, ref: any)
	local props: InternalProps = Sift.Dictionary.merge(defaultProps, providedProps)

	local err, setErr = React.useState(nil)

	React.useEffect(function()
		setErr(nil)
	end, { props.story, ref })

	React.useEffect(function()
		if props.story and ref.current then
			local success, result = xpcall(function()
				return mountStory(props.story, props.controls, ref.current)
			end, debug.traceback)

			if success then
				return result
			else
				setErr(result)
				return nil
			end
		end

		return nil
	end, { props.story, props.controls, props.isMountedInViewport, ref.current } :: { unknown })

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
