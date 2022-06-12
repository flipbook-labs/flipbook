local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)

local e = Roact.createElement

type Props = {
	anchorPoint: Vector2?,
	focused: boolean,
	onFocusLost: (instance: TextBox, enterPressed: boolean) -> (),
	placeholderText: string?,
	position: UDim2?,
	size: UDim2?,
	textSize: number?,
	textTransparency: number?,
}

local function WrappingTextbox(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local textbox = hooks.useValue(Roact.createRef())

	hooks.useEffect(function()
		if props.focused then
			textbox.value:getValue():CaptureFocus()
		end
	end, { textbox, props.focused })

	return e("ScrollingFrame", {
		AnchorPoint = props.anchorPoint,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Position = props.position,
		ScrollBarThickness = 0,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollingEnabled = false,
		Size = props.size,
	}, {
		Textbox = e("TextBox", {
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			PlaceholderColor3 = theme.text,
			PlaceholderText = props.placeholderText,
			Size = UDim2.fromScale(0, 1),
			Text = "",
			TextColor3 = theme.text,
			TextSize = props.textSize,
			TextTransparency = props.textTransparency,
			[Roact.Event.FocusLost] = props.onFocusLost,
			[Roact.Ref] = textbox.value,
		}),
	})
end

return hook(WrappingTextbox)
