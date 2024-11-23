local Navigation = require("@root/Navigation")
local React = require("@pkg/react")
local Sprite = require("@root/Common/Sprite")
local assets = require("@root/assets")
local useTheme = require("@root/Common/useTheme")

local e = React.createElement

type Props = {
	layoutOrder: number?,
	onPreviewInViewport: (() -> ())?,
	onZoomIn: (() -> ())?,
	onZoomOut: (() -> ())?,
	onViewCode: (() -> ())?,
	onExplorer: (() -> ())?,
}

local function NavbarRoot(props: Props)
	local theme = useTheme()

	return e(Navigation.Element, {
		height = 55,
		layoutOrder = props.layoutOrder,
	}, {
		LeftNav = e(Navigation.Items, {
			layoutOrder = 1,
		}, {
			Zoom = e(Navigation.Items, {
				layoutOrder = 2,
			}, {
				Magnify = e(Navigation.Item, {
					layoutOrder = 1,
					onClick = props.onZoomIn,
				}, {
					Icon = e(Sprite, {
						image = assets.Magnify,
						color = theme.textFaded,
						size = UDim2.fromOffset(24, 24),
					}),
				}),

				Minify = e(Navigation.Item, {
					layoutOrder = 2,
					onClick = props.onZoomOut,
				}, {
					Icon = e(Sprite, {
						image = assets.Minify,
						color = theme.textFaded,
						size = UDim2.fromOffset(24, 24),
					}),
				}),
			}),

			Divider = e(Navigation.Divider, {
				layoutOrder = 3,
			}),

			Mount = e(Navigation.Items, {
				layoutOrder = 4,
			}, {
				Explorer = e(Navigation.Item, {
					layoutOrder = 1,
					onClick = props.onExplorer,
				}, {
					Text = e("TextLabel", {
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						Font = theme.font,
						Size = UDim2.fromScale(0, 0),
						Text = "Explorer",
						TextColor3 = theme.textFaded,
						TextSize = theme.textSize,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),

				ViewCode = e(Navigation.Item, {
					layoutOrder = 1,
					onClick = props.onViewCode,
				}, {
					Text = e("TextLabel", {
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						Font = theme.font,
						Size = UDim2.fromScale(0, 0),
						Text = "View Code",
						TextColor3 = theme.textFaded,
						TextSize = theme.textSize,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),

				ViewportPreview = e(Navigation.Item, {
					layoutOrder = 2,
					onClick = props.onPreviewInViewport,
				}, {
					Text = e("TextLabel", {
						AutomaticSize = Enum.AutomaticSize.XY,
						BackgroundTransparency = 1,
						Font = theme.font,
						Size = UDim2.fromScale(0, 0),
						Text = "Preview in Viewport",
						TextColor3 = theme.textFaded,
						TextSize = theme.textSize,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),
				}),
			}),
		}),
	})
end

return NavbarRoot
