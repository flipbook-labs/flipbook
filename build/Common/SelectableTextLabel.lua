local React = require(script.Parent.Parent.Packages.React)
local Sift = require(script.Parent.Parent.Packages.Sift)
local useTheme = require(script.Parent.useTheme)

local defaultProps = {
	AutomaticSize = Enum.AutomaticSize.XY,
	BackgroundTransparency = 1,
	ClearTextOnFocus = false,
	ClipsDescendants = true,
	TextEditable = false,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}

type Props = {
	[string]: any,
}

local function SelectableTextLabel(providedProps: Props)
	local theme = useTheme()

	local props = Sift.Dictionary.merge(defaultProps, {
		TextSize = theme.textSize,
		Font = theme.font,
		TextColor3 = theme.text,
	}, providedProps)

	return React.createElement("TextBox", props)
end

return SelectableTextLabel
