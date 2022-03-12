local hook = require(script.Parent.Parent.hook)
local Roact = require(script.Parent.Parent.Packages.Roact)
local useTheme = require(script.Parent.Parent.Hooks.useThemeNew)

local e = Roact.createElement

local function Searchbar(_, hooks: any)
	local theme = useTheme(hooks)

	return e("Frame", {
		Size = UDim2.fromOffset(200, 32),
		Position = UDim2.fromOffset(20, 45),
		BackgroundTransparency = 1,
	}, {
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),

		UIStroke = e("UIStroke", {
			Color = theme.stroke,
		}),
	})
end

return hook(Searchbar)
