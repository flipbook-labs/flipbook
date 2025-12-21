local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local useTheme = require("@root/Common/useTheme")

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

local function SelectableTextLabel(providedProps)
	local theme = useTheme()

	local props = Sift.Dictionary.merge(defaultProps, {
		TextSize = theme.textSize,
		Font = theme.font,
		TextColor3 = theme.text,
	}, providedProps)

	return React.createElement("TextBox", props)
end

return SelectableTextLabel
