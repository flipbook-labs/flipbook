local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)
local assets = require(script.Parent.Parent.assets)

export type Props = {
	isChecked: boolean,
	onActivated: (boolean) -> (),
}

local function Checkbox(props: Props, hooks: any)
	local theme = useTheme(hooks)

	local onActivated = hooks.useCallback(function()
		props.onActivated(not props.isChecked)
	end, { props.isChecked })

	return Roact.createElement("ImageButton", {
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBackground),
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		ImageTransparency = 1,
		[Roact.Event.Activated] = onActivated,
	}, {
		Border = Roact.createElement("UIStroke", {
			Color = theme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Miter,
			Thickness = 3,
		}),

		Check = props.isChecked and Roact.createElement("ImageLabel", {
			Image = assets.checkmark,
			ImageColor3 = theme:GetColor(Enum.StudioStyleGuideColor.LinkText),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}),
	})
end

return RoactHooks.new(Roact)(Checkbox)
