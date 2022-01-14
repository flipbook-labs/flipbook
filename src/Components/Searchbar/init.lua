local Flipper = require(script.Parent.Parent.Packages.Flipper)
local hook = require(script.Parent.Parent.hook)
local Icon = require(script.Parent.Icon)
local Roact = require(script.Parent.Parent.Packages.Roact)
local useSingleMotor = require(script.Parent.Parent.Hooks.useSingleMotor)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)

local PADDING = UDim.new(0, 9)
local NO_PADDING = UDim.new(0, 0)
local SPRING_OPTIONS = {
	dampingRatio = 0.7,
	frequency = 6,
}

type Props = {
	position: UDim2?,
}

local function mapColors(spring, color1, color2)
	return spring:map(function(alpha)
		return color1:Lerp(color2, alpha)
	end)
end

local function Searchbar(props: Props, hooks: any)
	local theme = useTheme(hooks)
	local spring, setSpring = useSingleMotor(hooks, 0)
	local active = hooks.useState(false)

	hooks.useEffect(function()
		if active then
			setSpring(Flipper.Spring.new(0, SPRING_OPTIONS))
		else
			setSpring(Flipper.Spring.new(1))
		end
	end, { active, setSpring })

	return Roact.createElement("Frame", {
		BackgroundColor3 = theme.searchbar.background,
		BackgroundTransparency = spring,
		Position = props.position,
		Size = UDim2.fromOffset(200, 32),
	}, {
		UIPadding = Roact.createElement("UIPadding", {
			PaddingLeft = PADDING,
			PaddingRight = PADDING,
			PaddingTop = NO_PADDING,
			PaddingBottom = NO_PADDING,
		}),

		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),

		UIStroke = Roact.createElement("UIStroke", {
			Color = mapColors(spring, theme.searchbar.stroke, theme.stroke),
		}),

		Icon = Roact.createElement(Icon, {
			anchorPoint = Vector2.new(0, 0.5),
			color = mapColors(spring, theme.icons.search, theme.stroke),
			icon = "magnifying-glass",
			position = UDim2.fromScale(0, 0.5),
			size = 14,
		}),

		Divider = Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = mapColors(spring, theme.searchbar.stroke, theme.stroke),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 23, 0.5, 0),
			Size = UDim2.new(0, 1, 1, -8),
		}),
	})
end

return hook(Searchbar)
