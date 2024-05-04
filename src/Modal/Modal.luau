local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local useTheme = require("@root/Common/useTheme")

export type Props = {
	maxSize: Vector2?,
	content: React.Node?,
	onClose: () -> (),
}

local defaultProps = {
	maxSize = Vector2.new(500, math.huge),
}

type InternalProps = typeof(defaultProps) & Props

local function Modal(providedProps: Props)
	local props: InternalProps = Sift.Dictionary.join(defaultProps, providedProps)
	local theme = useTheme()

	return React.createElement("ImageButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.8,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		[React.Event.Activated] = props.onClose,
	}, {
		Layout = React.createElement("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		Window = React.createElement("ImageButton", {
			Active = true,
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundColor3 = theme.modal,
			BorderSizePixel = 0,
		}, {
			SizeConstraint = React.createElement("UISizeConstraint", {
				MaxSize = props.maxSize,
			}),

			Padding = React.createElement("UIPadding", {
				PaddingTop = theme.paddingLarge,
				PaddingRight = theme.paddingLarge,
				PaddingBottom = theme.paddingLarge,
				PaddingLeft = theme.paddingLarge,
			}),

			UICorner = React.createElement("UICorner", {
				CornerRadius = theme.corner,
			}),

			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = theme.paddingLarge,
			}),

			Header = React.createElement("Frame", {
				LayoutOrder = 1,
				AutomaticSize = Enum.AutomaticSize.Y,
				Size = UDim2.fromScale(1, 0),
				BackgroundTransparency = 1,
			}, {
				Title = React.createElement("TextLabel", {
					Text = "Example Modal",
					Font = theme.headerFont,
					TextColor3 = theme.text,
					TextSize = theme.headerTextSize,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
				}),

				Close = React.createElement("TextButton", {
					Font = Enum.Font.BuilderSansExtraBold,
					TextColor3 = theme.text,
					TextSize = theme.headerTextSize,
					Text = "X",
					AutomaticSize = Enum.AutomaticSize.XY,
					Position = UDim2.fromScale(1, 0),
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					[React.Event.Activated] = props.onClose,
				}),
			}),

			Content = React.createElement("Frame", {
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
			}, props.content),
		}),
	})
end

return Modal
