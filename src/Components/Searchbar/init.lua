local constants = require(script.Parent.Parent.constants)
local hook = require(script.Parent.Parent.hook)
local Icon = require(script.Parent.Icon)
local InputArea = require(script.InputArea)
local Roact = require(script.Parent.Parent.Packages.Roact)
local RoactSpring = require(script.Parent.Parent.Packages.RoactSpring)
local useTheme = require(script.Parent.Parent.Hooks.useThemeNew)

local e = Roact.createElement

type Props = {
	onSearchChanged: (string) -> (),
}

local function Searchbar(_, hooks: any)
	local theme = useTheme(hooks)
	local active, setActive = hooks.useState(false)
	local style = RoactSpring.useSpring(hooks, {
		alpha = if active then 0 else 1,
		config = constants.SPRING_CONFIG,
	})

	return e("Frame", {
		BackgroundColor3 = theme.searchbar.background,
		BackgroundTransparency = style.alpha,
		Position = UDim2.fromOffset(20, 45),
		Size = UDim2.fromOffset(200, 32),
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),

		UIStroke = e("UIStroke", {
			Color = style.alpha:map(function(value)
				return theme.searchbar.stroke:Lerp(theme.stroke, value)
			end),
		}),

		UIPadding = e("UIPadding", {
			PaddingBottom = UDim.new(0, 0),
			PaddingLeft = UDim.new(0, 9),
			PaddingRight = UDim.new(0, 9),
			PaddingTop = UDim.new(0, 0),
		}),

		Icon = e(Icon, {
			anchorPoint = Vector2.new(0, 0.5),
			color = style.alpha:map(function(value)
				return theme.icons.search:Lerp(theme.stroke, value)
			end),
			icon = "magnifying-glass",
			position = UDim2.fromScale(0, 0.5),
			size = 14,
		}),

		Divider = e("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = style.alpha:map(function(value)
				return theme.searchbar.stroke:Lerp(theme.stroke, value)
			end),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 23, 0.5, 0),
			Size = UDim2.new(0, 1, 1, -8),
		}),

		InputArea = e(InputArea, {
			active = active,
			alpha = style.alpha,
			setActive = setActive,
		}),

		Hitbox = e("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			[Roact.Event.Activated] = function()
				setActive(true)
			end,
		}),
	})
end

return hook(Searchbar)