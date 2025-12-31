local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local useTokens = Foundation.Hooks.useTokens

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
	local tokens = useTokens()

	local font = tokens.Typography.BodyMedium
	local color = tokens.Color.Content.Default

	local props = Sift.Dictionary.merge(defaultProps, {
		TextSize = font.FontSize,
		Font = font.Font,
		TextColor3 = color.Color3,
		TextTransparency = color.Transparency,
	}, providedProps)

	return React.createElement("TextBox", props)
end

return SelectableTextLabel
