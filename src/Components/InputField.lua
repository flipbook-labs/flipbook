local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)

local e = Roact.createElement

local defaultProps = {
	placeholder = "Input...",
	autoFocus = false,
}

export type Props = typeof(defaultProps) & {
	layoutOrder: number?,
	onSubmit: ((text: string) -> ()),
	onTextChange: ((new: string, old: string) -> ())?,
	validate: ((text: string) -> boolean)?,
	transform: ((newText: string, oldText: string) -> string)?,
}

local function InputField(props: Props, hooks: any)
	local ref = Roact.createRef()
	local text, setText = hooks.useState("")
	local isValid, setIsValid = hooks.useState(false)
	local theme = useTheme(hooks)

	local onFocusLost = hooks.useCallback(function(_rbx: TextBox, enterPressed: boolean)
		if enterPressed and isValid and props.onSubmit then
			props.onSubmit(text)
		end
	end, {
		isValid,
		props.onSubmit,
	})

	local onTextChanged = hooks.useCallback(function(rbx: TextBox)
		local newText = rbx.Text

		if newText == text then
			return
		end

		if props.transform then
			newText = props.transform(newText, text)
		end

		if props.onTextChange then
			props.onTextChange(newText, text)
		end

		setText(newText)

		if props.validate then
			setIsValid(props.validate(newText))
		end
	end, {})

	hooks.useEffect(function()
		if props.autoFocus then
			ref:getValue():CaptureFocus()
		end
	end, {
		props.autoFocus,
	})

	return e("TextBox", {
		LayoutOrder = props.layoutOrder,
		PlaceholderText = props.placeholder,
		TextSize = theme.textSize,
		TextColor3 = theme.text,
		Font = theme.font,
		-- LineHeight = 1.25,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.5, 0),
		PlaceholderColor3 = theme.textFaded,
		ClearTextOnFocus = false,
		Text = text,
		[Roact.Change.Text] = onTextChanged,
		[Roact.Event.FocusLost] = onFocusLost,
		[Roact.Ref] = ref,
	}, {
		Padding = e("UIPadding", {
			PaddingTop = theme.padding,
			PaddingRight = theme.padding,
			PaddingBottom = theme.padding,
			PaddingLeft = theme.padding,
		}),

		Corner = e("UICorner", {
			CornerRadius = UDim.new(1 / 4, 0),
		}),
	})
end

return hook(InputField, {
	defaultProps = defaultProps,
})
