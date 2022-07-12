local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local useTheme = require(flipbook.Hooks.useTheme)

local e = Roact.createElement

local defaultProps = {
	size = UDim2.fromScale(1, 1),
	placeholder = "Input...",
	autoFocus = false,
}

export type Props = typeof(defaultProps) & {
	layoutOrder: number?,
	onSubmit: ((text: string) -> ()),
	onFocus: (() -> ())?,
	onFocusLost: (() -> ())?,
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
		if props.onFocusLost then
			props.onFocusLost()
		end

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
		Size = props.size,
		TextSize = theme.textSize,
		TextColor3 = theme.text,
		Font = theme.font,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		BackgroundTransparency = 1,
		PlaceholderColor3 = theme.textFaded,
		ClearTextOnFocus = false,
		Text = text,
		ClipsDescendants = true,
		[Roact.Change.Text] = onTextChanged,
		[Roact.Event.Focused] = props.onFocus,
		[Roact.Event.FocusLost] = onFocusLost,
		[Roact.Ref] = ref,
	})
end

return hook(InputField, {
	defaultProps = defaultProps,
})
