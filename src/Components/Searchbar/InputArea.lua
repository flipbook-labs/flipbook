local flipbook = script:FindFirstAncestor("flipbook")

local Llama = require(flipbook.Packages.Llama)
local Roact = require(flipbook.Packages.Roact)
local hook = require(flipbook.hook)
local styles = require(flipbook.styles)
local mapRanges = require(flipbook.Modules.mapRanges)
local useTheme = require(flipbook.Hooks.useTheme)
local WrappingTextbox = require(flipbook.Components.WrappingTextbox)

local e = Roact.createElement

type Props = {
	active: boolean,
	alpha: any,
	setActive: (boolean) -> (),
}

local function InputArea(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return e("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.new(0, 32, 0.5, 0),
		Size = UDim2.new(1, -32, 1, 0),
	}, {
		DeactivatedText = e(
			"TextLabel",
			Llama.Dictionary.join(styles.TextLabel, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = props.alpha:map(function(value)
					return UDim2.new(0, mapRanges(value, 0, 1, -10, 0), 0.5, 0)
				end),
				Text = "Find components",
				TextColor3 = theme.stroke,
				TextSize = 14,
				TextTransparency = props.alpha:map(function(value)
					return 1 - value
				end),
			})
		),

		ActivatedText = e(WrappingTextbox, {
			anchorPoint = Vector2.new(0, 0.5),
			focused = props.active,
			onFocusLost = function()
				props.setActive(false)
			end,
			position = props.alpha:map(function(value)
				return UDim2.new(0, mapRanges(value, 0, 1, 0, -10), 0.5, 0)
			end),
			placeholderText = "Type to find...",
			size = UDim2.new(1, -32, 1, 0),
			textSize = 14,
			textTransparency = props.alpha,
		}),
	})
end

return hook(InputArea)
