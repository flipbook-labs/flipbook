local hook = require(script.Parent.Parent.Parent.hook)
local mapRanges = require(script.Parent.Parent.Parent.Modules.mapRanges)
local Roact = require(script.Parent.Parent.Parent.Packages.Roact)
local useTheme = require(script.Parent.Parent.Parent.Hooks.useTheme)
local WrappingTextbox = require(script.Parent.Parent.WrappingTextbox)

type Props = {
	active: boolean,
	setActive: (active: boolean) -> (),
	spring: any,
}

local function InputArea(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return Roact.createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0, 32, 0.5, 0),
		Size = UDim2.new(1, -32, 1, 0),
	}, {
		Deactivated = Roact.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			Position = props.spring:map(function(alpha)
				return UDim2.new(0, mapRanges(alpha, 0, 1, -10, 0), 0.5, 0)
			end),
			Size = UDim2.fromScale(1, 1),
			Text = "Find components",
			TextColor3 = theme.stroke,
			TextSize = 14,
			TextTransparency = props.spring:map(function(alpha)
				return 1 - alpha
			end),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),

		Activated = Roact.createElement(WrappingTextbox, {
			anchorPoint = Vector2.new(0, 0.5),
			focused = props.active,
			onFocusLost = function()
				props.setActive(false)
			end,
			placeholderText = "Type to find...",
			position = props.spring:map(function(alpha)
				return UDim2.new(0, mapRanges(alpha, 0, 1, 0, -10), 0.5, 0)
			end),
			size = UDim2.fromScale(1, 1),
			text = "",
			textSize = 14,
			textTransparency = props.spring,
		}),
	})
end

return hook(InputArea)
