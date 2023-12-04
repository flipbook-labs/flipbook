local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Sift = require(flipbook.Packages.Sift)
local useTheme = require(flipbook.Common.useTheme)

local e = React.createElement

local defaultProps = {
	size = UDim2.fromScale(1, 1),
	placeholder = "Input...",
	autoFocus = false,
}

export type Props = typeof(defaultProps) & {
	layoutOrder: number?,
	onSubmit: (text: string) -> (),
	onFocus: (() -> ())?,
	onFocusLost: (() -> ())?,
	onTextChange: ((new: string, old: string) -> ())?,
	validate: ((text: string) -> boolean)?,
	transform: ((newText: string, oldText: string) -> string)?,
}

local function InputField(props: Props)
	props = Sift.Dictionary.merge(defaultProps, props)

	local ref = React.createRef()
	local text, setText = React.useState("")
	local isValid, setIsValid = React.useState(false)
	local theme = useTheme()

	local onFocusLost = React.useCallback(function(_rbx: TextBox, enterPressed: boolean)
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

	local onTextChanged = React.useCallback(function(rbx: TextBox)
		local newText = rbx.Text

		if newText == text and newText ~= "" then
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

	React.useEffect(function()
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
		ref = ref,
		[React.Change.Text] = onTextChanged,
		[React.Event.Focused] = props.onFocus,
		[React.Event.FocusLost] = onFocusLost,
	})
end

return InputField
