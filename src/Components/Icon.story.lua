local Icon = require(script.Parent.Icon)
local Roact = require(script.Parent.Parent.Packages.Roact)
local themes = require(script.Parent.Parent.themes)

return {
	story = Roact.createElement(Icon, {
		color = themes.Light.icons.folder,
		icon = "folder",
		position = UDim2.fromOffset(20, 20),
		size = UDim2.fromOffset(28, 20),
	}),
}
