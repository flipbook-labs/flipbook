local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local styles = require(script.Parent.Parent.styles)
local themes = require(script.Parent.Parent.themes)

type Props = {
	anchorPoint: Vector2?,
	layoutOrder: number?,
	position: UDim2?,
	size: number?,
}

local function Branding(props: Props)
	return Roact.createElement(
		"TextLabel",
		Llama.Dictionary.join(styles.TextLabel, {
			AnchorPoint = props.anchorPoint or Vector2.new(0, 0),
			Font = Enum.Font.GothamBlack,
			LayoutOrder = props.layoutOrder,
			Position = props.position,
			Text = "flipbook",
			TextColor3 = themes.Brand,
			TextSize = props.size,
		})
	)
end

return Branding
