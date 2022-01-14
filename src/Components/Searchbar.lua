local hook = require(script.Parent.Parent.hook)
local Icon = require(script.Parent.Icon)
local Roact = require(script.Parent.Parent.Packages.Roact)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)

type Props = {
	position: UDim2?,
}

local function Searchbar(props: Props, hooks: any)
	local theme = useTheme(hooks)

	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Position = props.position,
		Size = UDim2.fromOffset(200, 32),
	}, {
		UICorner = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),

		UIStroke = Roact.createElement("UIStroke", {
			Color = theme.stroke,
		}),

		Icon = Roact.createElement(Icon, {
			color = theme.icons.search,
			icon = "magnifying-glass",
			size = 14,
		}),
	})
end

return hook(Searchbar)
