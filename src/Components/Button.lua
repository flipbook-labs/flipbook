local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactHooks = require(script.Parent.Parent.Packages.RoactHooks)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)
local styles = require(script.Parent.Parent.styles)

local TEXT_SIZE = 14

export type Props = {
	text: string?,
	layoutOrder: number?,
	maxSize: Vector2?,
	onActivated: (() -> nil)?,
}

local function Button(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return Roact.createElement("TextButton", {
		Text = props.text,
		LayoutOrder = props.layoutOrder,
		TextSize = TEXT_SIZE,
		Font = Enum.Font.GothamBold,
		TextColor3 = theme:GetColor(Enum.StudioStyleGuideColor.ButtonText),
		BackgroundColor3 = theme:GetColor(Enum.StudioStyleGuideColor.Button),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		AutomaticSize = Enum.AutomaticSize.XY,
		[Roact.Event.Activated] = props.onActivated,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = styles.PADDING,
			PaddingRight = styles.PADDING,
			PaddingBottom = styles.PADDING,
			PaddingLeft = styles.PADDING,
		}),

		Border = Roact.createElement("UIStroke", {
			Color = theme:GetColor(Enum.StudioStyleGuideColor.ButtonBorder),
			Thickness = 2,
		}),
	})
end

return RoactHooks.new(Roact)(Button)
