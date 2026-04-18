local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local FoundationProvider = Foundation.FoundationProvider
local Image = Foundation.Image

local function App()
	return React.createElement(FoundationProvider, nil, {
		Background = React.createElement(Image, {
			Image = "rbxassetid://109801102767935",
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromOffset(4, 4),
			imageStyle = { Color3 = Color3.new(1, 1, 1), Transparency = 0.975 },
			tag = "bg-surface-0 padding-medium size-full",
		}),
	})
end

return React.memo(App)
