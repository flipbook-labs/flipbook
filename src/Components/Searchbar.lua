local hook = require(script.Parent.Parent.hook)
local Roact = require(script.Parent.Parent.Packages.Roact)
local useTheme = require(script.Parent.Parent.Hooks.useTheme)

type Props = {
	position: UDim2?,
}

local function Searchbar(props, hooks)
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
	})
end

return hook(Searchbar)
