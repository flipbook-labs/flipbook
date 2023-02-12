local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)
local Sift = require(flipbook.Packages.Sift)
local useTheme = require(flipbook.Hooks.useTheme)

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
