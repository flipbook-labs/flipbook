local CoreGui = game:GetService("CoreGui")

local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Sift = require("@pkg/Sift")
local Storyteller = require("@pkg/Storyteller")

local StoryError = require("@root/Storybook/StoryError")
local useHoveredGuiObjects = require("@root/Common/useHoveredGuiObjects")
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

	local hoveredObjects = useHoveredGuiObjects(ref.current)
	local depth, setDepth = React.useState(1)
	local highlightedObject = hoveredObjects[depth]

	React.useEffect(function(): (() -> ())?
		if #hoveredObjects <= 0 then
			return nil
		end

		local connections = {}

		for _, hoveredObject in hoveredObjects do
			if hoveredObject:IsA("GuiButton") then
				table.insert(
					connections,
					hoveredObject.Activated:Connect(function()
						setDepth(function(prevDepth)
							return math.clamp(prevDepth + 1, 0, #hoveredObjects)
						end)
					end)
				)
			end
		end

		return function()
			for _, connection in connections do
				connection:Disconnect()
			end
		end
	end, { hoveredObjects })

	print("hoveredObjects", hoveredObjects)

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
			return e(Foundation.ScrollView, {
				tag = "size-full",
				scroll = {
					ScrollingDirection = Enum.ScrollingDirection.XY,
					AutomaticCanvasSize = Enum.AutomaticSize.XY,
					CanvasSize = UDim2.new(0, 0),
				},
				LayoutOrder = props.layoutOrder,
				scrollingFrameRef = ref,
			}, {
				Highlight = if highlightedObject
					then ReactRoblox.createPortal({
						Highlight = e("Frame", {
							BorderSizePixel = 4,
							Size = UDim2.fromScale(1, 1),
							ZIndex = 10,
						}),
					}, highlightedObject)
					else nil,

				Scale = e("UIScale", {
					Scale = 1 + props.zoom,
				}),
			})
		end
	end
end)

return StoryPreview
