local React = require("@pkg/React")

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
		if navigation.currentScreen == "Settings" then
			navigation.goBack()
		else
			navigation.navigateTo("Settings")
		end
	end, { navigation.navigateTo, navigation.currentScreen })

	local navigateToAbout = useCallback(function()
		if navigation.currentScreen == "About" then
			navigation.goBack()
		else
			navigation.navigateTo("About")
		end
	end, { navigation.navigateTo, navigation.currentScreen })

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

-- local function Topbar(props: Props)
-- 	local theme = useTheme()
-- 	local navigation = NavigationContext.use()

-- 	return React.createElement("Frame", {
-- 		Size = UDim2.fromScale(1, 1),
-- 		BackgroundColor3 = theme.sidebar,
-- 		BorderSizePixel = 0,
-- 	}, {
-- 		LayoutOrder = React.createElement("UIListLayout", {
-- 			SortOrder = Enum.SortOrder.LayoutOrder,
-- 			HorizontalAlignment = Enum.HorizontalAlignment.Right,
-- 		}),

-- 		Navbar = React.createElement("Frame", {}, {
-- 			LayoutOrder = React.createElement("UIListLayout", {
-- 				SortOrder = Enum.SortOrder.LayoutOrder,
-- 				HorizontalAlignment = Enum.HorizontalAlignment.Right,
-- 			}),

-- 			Settings = React.createElement(Button, {
-- 				layoutOrder = nextLayoutOrder(),
-- 				text = "Settings",
-- 			}),
-- 		}),
-- 	})
-- end

-- return Topbar
