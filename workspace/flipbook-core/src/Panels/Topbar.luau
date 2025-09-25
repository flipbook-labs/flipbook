local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local AboutView = require("@root/About/AboutView")
local NavigationContext = require("@root/Navigation/NavigationContext")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")

local useCallback = React.useCallback
local useState = React.useState
local useMemo = React.useMemo
local useRef = React.useRef

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

	local isHelpMenuOpen, setIsHelpMenuOpen = useState(false)
	local helpButtonRef = useRef(nil :: GuiObject?)
	local isAboutDialogOpen, setIsAboutDialogOpen = useState(false)

	local helpMenuItems = useMemo(function(): { Foundation.MenuItem }
		return {
			{
				id = "about",
				text = "About",
				onActivated = function()
					setIsAboutDialogOpen(true)
					setIsHelpMenuOpen(false)
				end,
			},
		}
	end, {})

	return React.createElement(Foundation.View, {
		tag = "size-full-0 auto-y bg-surface-0 row gap-small padding-xsmall align-x-right",
		LayoutOrder = props.LayoutOrder,
	}, {
		SettingsButton = React.createElement(Foundation.IconButton, {
			icon = Foundation.Enums.IconName.Gear,
			size = Foundation.Enums.InputSize.Small,
			LayoutOrder = nextLayoutOrder(),
			onActivated = navigateToSettings,
		}),

		HelpButton = React.createElement(Foundation.IconButton, {
			icon = Foundation.Enums.IconName.CircleQuestion,
			size = Foundation.Enums.InputSize.Small,
			LayoutOrder = nextLayoutOrder(),
			ref = helpButtonRef,
			onActivated = function()
				setIsHelpMenuOpen(true)
			end,
		}),

		HelpMenu = React.createElement(Foundation.Menu, {
			isOpen = isHelpMenuOpen,
			items = helpMenuItems,
			anchorRef = helpButtonRef,
			onPressedOutside = function()
				setIsHelpMenuOpen(function(prev)
					return not prev
				end)
			end,
		}),

		AboutDialog = if isAboutDialogOpen
			then React.createElement(Foundation.Dialog.Root, {
				disablePortal = false,
				hasBackdrop = true,
				onClose = function()
					setIsAboutDialogOpen(false)
				end,
			}, {
				Title = React.createElement(Foundation.Dialog.Title, {
					text = "About",
				}),

				Content = React.createElement(Foundation.Dialog.Content, nil, {
					AboutView = React.createElement(AboutView),
				}),
			})
			else nil,
	})
end

return Topbar
