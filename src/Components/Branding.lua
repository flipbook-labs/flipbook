local Roact = require(script.Parent.Parent.Packages.Roact)
local themes = require(script.Parent.Parent.themes)

type Props = {
	layoutOrder: number?,
	position: UDim2?,
	size: number?,
}

local function Branding(props)
	return Roact.createElement("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		LayoutOrder = props.layoutOrder or 1,
		Position = props.position or UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(0, 0),
		Text = "flipbook",
		TextColor3 = themes.Brand,
		TextSize = props.size or 20,
	})
end

return Branding
