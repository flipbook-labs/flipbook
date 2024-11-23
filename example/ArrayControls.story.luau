local React = require("@pkg/react")
local ReactRoblox = require("@pkg/react-roblox")
local Sift = require("@pkg/sift")

local fonts = Sift.Array.sort(Enum.Font:GetEnumItems(), function(a: Enum.Font, z: Enum.Font)
	return a.Name < z.Name
end)
fonts = Sift.Array.unshift(fonts, Enum.Font.Gotham)

local controls = {
	font = fonts,
}

type Props = {
	controls: {
		font: Enum.Font,
	},
}

return {
	summary = "Example of using array controls to set the font for a TextLabel",
	controls = controls,
	react = React,
	reactRoblox = ReactRoblox,
	story = function(props: Props)
		return React.createElement("TextLabel", {
			Text = props.controls.font.Name,
			Font = props.controls.font,
			TextScaled = true,
			TextColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Size = UDim2.fromOffset(300, 100),
		})
	end,
}
