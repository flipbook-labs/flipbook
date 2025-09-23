local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useHoveredGuiObjects = require("@root/Common/useHoveredGuiObjects")

local useTokens = Foundation.Hooks.useTokens
local useOverlay = Foundation.Hooks.useOverlay

export type Props = {
	hoverRef: { current: GuiObject? },
}

local function HoverHighlighter(props: Props): React.Node
	local overlay = useOverlay()
	local tokens = useTokens()
	local hoveredObjects = useHoveredGuiObjects(if props.hoverRef then props.hoverRef.current else nil)
	local highlightedObject = hoveredObjects[1]

	if not highlightedObject then
		return nil
	end

	-- TODO: If highlightedObject's position or size changes make sure to
	-- trigger a re-render

	local absSize = highlightedObject.AbsoluteSize
	local absPosition = highlightedObject.AbsolutePosition

	local root = React.createElement(Foundation.View, {
		tag = "col align-y-center gap-small",
		Size = UDim2.fromOffset(absSize.X, absSize.Y),
		Position = UDim2.fromOffset(absPosition.X, absPosition.Y),
	}, {

		Name = React.createElement(Foundation.Text, {
			tag = "auto-xy text-label-medium bg-over-media-100 padding-xsmall",
			Text = highlightedObject.Name,
			LayoutOrder = nextLayoutOrder(),
		}),

		Inner = React.createElement(Foundation.View, {
			tag = "size-full",
			-- onActivated = function()
			-- 	print("clicked on", highlightedObject)
			-- end,
			stroke = {
				Color = tokens.Color.Extended.Turquoise.Turquoise_700.Color3,
				Transparency = tokens.Color.Extended.Turquoise.Turquoise_700.Transparency,
				Thickness = 2,
			},
			LayoutOrder = nextLayoutOrder(),
		}),

		DimensionsWrapper = React.createElement(Foundation.View, {
			tag = "size-full-0 auto-y row align-x-center ",
			LayoutOrder = nextLayoutOrder(),
		}, {
			Label = React.createElement(Foundation.Text, {
				tag = "auto-xy text-label-medium padding-xsmall",
				backgroundStyle = tokens.Color.Extended.Turquoise.Turquoise_700,
				Text = `{math.round(absSize.X)} x {math.round(absSize.Y)}`,
			}),
		}),
	})

	if overlay then
		return ReactRoblox.createPortal(root, overlay)
	else
		return root
	end
end

return HoverHighlighter
