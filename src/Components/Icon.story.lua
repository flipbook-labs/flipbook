local Icon = require(script.Parent.Icon)
local Roact = require(script.Parent.Parent.Packages.Roact)
local themes = require(script.Parent.Parent.themes)

local function deriveIconSize(icon: string): UDim2?
	if icon == "folder" then
		return UDim2.fromOffset(14, 10)
	elseif icon == "story" then
		return UDim2.fromOffset(14, 14)
	end
	return nil
end

return {
	summary = "Show's off the various icons we use in our plugin.",
	controls = {
		Icon = "folder",
	},

	story = function(props)
		local icon = if themes.Light.icons[props.controls.Icon] then props.controls.Icon else "folder"

		return Roact.createElement(Icon, {
			color = themes.Light.icons[icon],
			icon = icon,
			position = UDim2.fromOffset(20, 20),
			size = deriveIconSize(icon),
		})
	end,
	roact = Roact,
}
