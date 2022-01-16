local hook = require(script.Parent.Parent.hook)
local Roact = require(script.Parent.Parent.Packages.Roact)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)

type Props = {
	anchorPoint: Vector2?,
	focused: boolean?,
	onFocusLost: (instance: TextBox, enterPressed: boolean) -> (),
	placeholderText: string?,
	position: UDim2?,
	size: UDim2?,
	text: string?,
	textSize: number?,
	textTransparency: number?,
}

local function WrappingTextbox(props: Props, hooks: any)
	local ref = hooks.useValue(Roact.createRef())
	local theme = useTheme(hooks)

	hooks.useEffect(function()
		if props.focused == true then
			ref.value:getValue():CaptureFocus()
		end
	end, { props.focused })

	return Roact.createElement("TextBox", {
		AnchorPoint = props.anchorPoint,
		BackgroundTransparency = 1,
		Font = Enum.Font.Gotham,
		PlaceholderColor3 = theme.text,
		PlaceholderText = props.placeholderText,
		Position = props.position,
		Size = props.size,
		Text = props.text,
		TextColor3 = theme.text,
		TextSize = props.textSize,
		TextTransparency = props.textTransparency,
		TextXAlignment = Enum.TextXAlignment.Left,
		[Roact.Event.FocusLost] = props.onFocusLost,
		[Roact.Ref] = ref.value,
	})
end

return hook(WrappingTextbox)
