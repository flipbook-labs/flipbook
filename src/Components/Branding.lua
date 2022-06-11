local flipbook = script:FindFirstAncestor("flipbook")

local Llama = require(flipbook.Packages.Llama)
local Roact = require(flipbook.Packages.Roact)
local styles = require(flipbook.styles)
local themes = require(flipbook.themes)

local e = Roact.createElement

type Props = {
	anchorPoint: Vector2?,
	layoutOrder: number?,
	position: UDim2?,
	size: number?,
	tag: string?,
	tagColor: Color3?,
	tagSize: number?,
}

local function Branding(props: Props)
	if props.tag then
		return e("Frame", {
			AnchorPoint = props.anchorPoint,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = props.layoutOrder,
			Position = props.position,
			Size = UDim2.fromOffset(0, 0),
		}, {
			UIListLayout = e("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Branding = e(Branding, {
				layoutOrder = 0,
				size = props.size,
			}),

			Tag = e("Frame", {
				LayoutOrder = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				Size = UDim2.fromOffset(0, 0),
				BackgroundColor3 = props.tagColor,
			}, {
				UICorner = e("UICorner", {
					CornerRadius = UDim.new(0, 2),
				}),

				UIPadding = e("UIPadding", {
					PaddingBottom = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
					PaddingTop = UDim.new(0, 4),
				}),

				Tag = e(
					"TextLabel",
					Llama.Dictionary.join(styles.TextLabel, {
						Font = Enum.Font.GothamBlack,
						Text = props.tag,
						TextColor3 = Color3.new(1, 1, 1),
						TextSize = props.tagSize,
					})
				),
			}),
		})
	else
		return e(
			"TextLabel",
			Llama.Dictionary.join(styles.TextLabel, {
				AnchorPoint = props.anchorPoint,
				Font = Enum.Font.GothamBlack,
				LayoutOrder = props.layoutOrder,
				Position = props.position,
				Text = "flipbook",
				TextColor3 = themes.Light.brand,
				TextSize = props.size,
			})
		)
	end
end

return Branding
