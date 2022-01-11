local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)
local assets = require(script.Parent.Parent.assets)

type Props = {
	isExpanded: boolean,
	position: UDim2?,
	anchorPoint: Vector2?,
	onActivated: (() -> nil)?,
}

local function SidebarToggle(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return Roact.createElement("ImageButton", {
		Position = props.position,
		AnchorPoint = props.anchorPoint,
		Image = assets["double-arrow"],
		Rotation = if props.isExpanded then 180 else 0,
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromOffset(20, 28),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.MainBackground),
		ZIndex = 10,
		[Roact.Event.Activated] = props.onActivated,
	}, {
		Border = Roact.createElement("UIStroke", {
			Color = theme:GetColor(Enum.StudioStyleGuideColor.Border),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 2,
		}),
	})
end

return RoactHooks.new(Roact)(SidebarToggle)
