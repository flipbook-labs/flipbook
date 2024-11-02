local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local useTheme = require("@root/Common/useTheme")

local e = React.createElement

local defaultProps = {
	size = UDim2.fromScale(1, 1),
	placeholder = "Input...",
	autoFocus = false,
}

export type Props = {
	layoutOrder: number?,
	onSubmit: (text: string, isValid: boolean) -> (),
	onFocus: (() -> ())?,
	onFocusLost: (text: string, isValid: boolean) -> (),
	onTextChange: ((new: string, old: string) -> ())?,
	validate: ((text: string) -> boolean)?,
	transform: ((newText: string, oldText: string) -> string)?,
}

type InternalProps = Props & typeof(defaultProps)

local function InputField(providedProps: Props)
	local props: InternalProps = Sift.Dictionary.merge(defaultProps, providedProps)

	local ref = React.useRef(nil :: TextBox?)
	local text, setText = React.useState("")
	local isValid, setIsValid = React.useState(false)
	local theme = useTheme()

	local onFocusLost = React.useCallback(
		function(_rbx: TextBox, enterPressed: boolean)
			if props.onFocusLost then
				props.onFocusLost(text, isValid)
			end

			if enterPressed and props.onSubmit then
				props.onSubmit(text, isValid)
			end
		end,
		{
			text,
			isValid,
			props.onSubmit,
		} :: { unknown }
	)

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
	end, { text, props.transform, props.validate, props.onTextChange } :: { unknown })

	React.useEffect(function()
		if ref.current and props.autoFocus then
			ref.current:CaptureFocus()
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
		[React.Event.Focused] = props.onFocus :: any,
		[React.Event.FocusLost] = onFocusLost :: any,
	})
end

return InputField
