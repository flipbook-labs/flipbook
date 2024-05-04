local React = require("@pkg/React")

local Navigation = require("@root/Navigation")
local NavigationContext = require("@root/Navigation/NavigationContext")
local Sprite = require("@root/Common/Sprite")
local assets = require("@root/assets")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local useCallback = React.useCallback

export type Props = {
	LayoutOrder: number?,
}

local function NavbarRoot(props: Props)
	local theme = useTheme()
	local navigation = NavigationContext.use()

	local navigateToSettings = useCallback(function()
		navigation.navigateTo("Settings")
	end, { navigation.navigateTo })

	return React.createElement(Navigation.Items, {
		layoutOrder = props.LayoutOrder,
	}, {
		Padding = React.createElement("UIPadding", {
			PaddingTop = theme.paddingSmall,
			PaddingRight = theme.paddingSmall,
			PaddingBottom = theme.paddingSmall,
			PaddingLeft = theme.paddingSmall,
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
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
			}),
		}),
	})
end

return NavbarRoot

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
