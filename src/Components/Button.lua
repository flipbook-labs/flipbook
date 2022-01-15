local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)
local styles = require(script.Parent.Parent.styles)

export type Props = {
	text: string?,
	icon: string?,
	layoutOrder: number?,
	maxSize: Vector2?,
	onActivated: (() -> ())?,
}

local function Button(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return Roact.createElement("ImageButton", {
		LayoutOrder = props.layoutOrder,
		BorderSizePixel = 0,
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button),
		AutomaticSize = Enum.AutomaticSize.XY,
		[Roact.Event.Activated] = props.onActivated,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = styles.SMALL_PADDING,
		}),

		Padding = Roact.createElement("UIPadding", {
			PaddingTop = styles.SMALL_PADDING,
			PaddingRight = styles.SMALL_PADDING,
			PaddingBottom = styles.SMALL_PADDING,
			PaddingLeft = styles.SMALL_PADDING,
		}),

		Border = Roact.createElement("UIStroke", {
			Color = theme:GetColor(Enum.StudioStyleGuideColor.ButtonBorder),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 2,
		}),

		Icon = props.icon and Roact.createElement("ImageLabel", {
			LayoutOrder = 1,
			Image = props.icon,
			Size = UDim2.fromOffset(24, 24),
			BackgroundTransparency = 1,
		}),

		Label = props.text and Roact.createElement("TextLabel", {
			LayoutOrder = 2,
			Text = props.text,
			TextSize = 14,
			TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonText),
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
		}),
	})
end

return RoactHooks.new(Roact)(Button)
