local CoreGui = game:GetService("CoreGui")

local Foundation = require(script.Parent.Parent.RobloxPackages.Foundation)
local React = require(script.Parent.Parent.Packages.React)
local ReactRoblox = require(script.Parent.Parent.Packages.ReactRoblox)
local Sift = require(script.Parent.Parent.Packages.Sift)
local Storyteller = require(script.Parent.Parent.Packages.Storyteller)

local StoryError = require(script.Parent.StoryError)
local usePrevious = require(script.Parent.Parent.Common.usePrevious)

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
