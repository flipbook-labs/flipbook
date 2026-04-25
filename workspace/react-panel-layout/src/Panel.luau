local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local GroupContext = require("./GroupContext")

export type PanelProps = {
	id: string?,
	LayoutOrder: number?,
	minSize: Vector2?,
	maxSize: Vector2?,
	defaultSize: Vector2?,
	children: React.Node?,
}

local defaultProps = {
	minSize = Vector2.new(100, 100),
	maxSize = Vector2.new(math.huge, math.huge),
	defaultSize = Vector2.new(200, 200),
}

type Props = typeof(defaultProps) & PanelProps

local function Panel(panelProps: PanelProps)
	local props: Props = Sift.Dictionary.join(defaultProps, panelProps)

	local groupContext = GroupContext.use()

	-- Register constraints with Group every render so Group has up-to-date
	-- min/max values for clamping. Weight is only initialized once (on first
	-- register when the weight slot is nil in Group state).
	local panelId = props.id
	if panelId then
		groupContext.registerPanel(panelId, {
			minSize = props.minSize,
			maxSize = props.maxSize,
		})
	end

	local weight = if panelId then (groupContext.weights[panelId] or 1) else nil

	return React.createElement(Foundation.ScrollView, {
		tag = {
			["padding-medium bg-surface-300"] = true,
		},
		Size = UDim2.new(0, 0, 0, 0),
		flexItem = if weight
			then {
				FlexMode = Enum.UIFlexMode.Custom,
				GrowRatio = weight,
			}
			else nil,
		sizeConstraint = {
			MinSize = props.minSize,
		},
		scroll = {
			AutomaticSize = Enum.AutomaticSize.XY,
			AutomaticCanvasSize = Enum.AutomaticSize.XY,
			CanvasSize = UDim2.fromScale(0, 0),
			ScrollingDirection = Enum.ScrollingDirection.Y,
		},
		layout = {
			FillDirection = groupContext.fillDirection,
		},
		LayoutOrder = props.LayoutOrder,
	}, props.children)
end

return React.memo(Panel)
