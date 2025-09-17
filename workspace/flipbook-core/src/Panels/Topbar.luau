local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local NavigationContext = require("@root/Navigation/NavigationContext")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useCallback = React.useCallback

export type Props = {
	LayoutOrder: number?,
}

local function Topbar(props: Props)
	local navigation = NavigationContext.use()

	local navigateToSettings = useCallback(function()
		if navigation.currentScreen ~= "Settings" then
			navigation.navigateTo("Settings")
		else
			navigation.navigateTo("Home")
		end
	end, { navigation.navigateTo, navigation.currentScreen } :: { unknown })

	local navigateToAbout = useCallback(function()
		if navigation.currentScreen ~= "About" then
			navigation.navigateTo("About")
		else
			navigation.navigateTo("Home")
		end
	end, { navigation.navigateTo, navigation.currentScreen } :: { unknown })

	return React.createElement(Foundation.View, {
		tag = "size-full-0 auto-y bg-surface-0 row gap-small padding-small align-x-right",
		LayoutOrder = props.LayoutOrder,
	}, {
		About = React.createElement(Foundation.Button, {
			text = "About",
			size = Foundation.Enums.ButtonSize.Small,
			LayoutOrder = nextLayoutOrder(),
			onActivated = navigateToAbout,
		}),

		Settings = React.createElement(Foundation.Button, {
			text = "Settings",
			size = Foundation.Enums.ButtonSize.Small,
			LayoutOrder = nextLayoutOrder(),
			onActivated = navigateToSettings,
		}),
	})
end

return Topbar
