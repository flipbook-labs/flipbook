local React = require("@pkg/react")

local Navigation = require("@root/Navigation")
local NavigationContext = require("@root/Navigation/NavigationContext")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local useCallback = React.useCallback

export type Props = {
	Size: UDim2?,
	LayoutOrder: number?,
}

local function Topbar(props: Props)
	local theme = useTheme()
	local navigation = NavigationContext.use()

	local navigateToSettings = useCallback(function()
		navigation.navigateTo("Settings")
	end, { navigation.navigateTo })

	local navigateToAbout = useCallback(function()
		navigation.navigateTo("About")
	end, { navigation.navigateTo })

	return React.createElement("Frame", {
		BackgroundColor3 = theme.sidebar,
		LayoutOrder = props.LayoutOrder,
		Size = props.Size,
	}, {
		Layout = React.createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
		}),

		NavItems = React.createElement(Navigation.Items, {
			layoutOrder = props.LayoutOrder,
		}, {
			Padding = React.createElement("UIPadding", {
				PaddingTop = theme.paddingSmall,
				PaddingRight = theme.paddingSmall,
				PaddingBottom = theme.paddingSmall,
				PaddingLeft = theme.paddingSmall,
			}),

			About = React.createElement(Navigation.Item, {
				layoutOrder = nextLayoutOrder(),
				onClick = navigateToAbout,
			}, {
				Text = React.createElement("TextLabel", {
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					Font = theme.font,
					Size = UDim2.fromScale(0, 0),
					Text = "About",
					TextColor3 = theme.textFaded,
					TextSize = theme.textSize,
				}),
			}),

			Settings = React.createElement(Navigation.Item, {
				layoutOrder = nextLayoutOrder(),
				onClick = navigateToSettings,
			}, {
				Text = React.createElement("TextLabel", {
					AutomaticSize = Enum.AutomaticSize.XY,
					BackgroundTransparency = 1,
					Font = theme.font,
					Size = UDim2.fromScale(0, 0),
					Text = "Settings",
					TextColor3 = theme.textFaded,
					TextSize = theme.textSize,
				}),
			}),
		}),
	})
end

return Topbar
