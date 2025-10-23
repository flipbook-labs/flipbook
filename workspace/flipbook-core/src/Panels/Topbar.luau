local AboutView = require("@root/About/AboutView")
local Foundation = require("@rbxpkg/Foundation")
local LuauPolyfill = require("@rbxpkg/LuauPolyfill")
local NavigationContext = require("@root/Navigation/NavigationContext")
local React = require("@pkg/React")
local ReactSignals = require("@rbxpkg/SignalsReact")
local StoryActionsContext = require("@root/Storybook/StoryActionsContext")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")

local Object = LuauPolyfill.Object

local Dialog = Foundation.Dialog
local Divider = Foundation.Divider
local Dropdown = Foundation.Dropdown
local IconButton = Foundation.IconButton
local IconName = Foundation.Enums.IconName
local IconVariant = Foundation.Enums.IconVariant
local InputSize = Foundation.Enums.InputSize
local Menu = Foundation.Menu
local Orientation = Foundation.Enums.Orientation
local PopoverAlign = Foundation.Enums.PopoverAlign
local PopoverSide = Foundation.Enums.PopoverSide
local Tooltip = Foundation.Tooltip
local View = Foundation.View
local withCommonProps = Foundation.Utility.withCommonProps

local e = React.createElement
local useCallback = React.useCallback
local useRef = React.useRef
local useState = React.useState

local useSignalState = ReactSignals.useSignalState

type ItemId = number | string

type TopbarProps = {} & Foundation.CommonProps

local function Topbar(props: TopbarProps)
	local helpButtonRef = useRef(nil :: GuiObject?)

	local isAboutMenuOpen, setIsAboutMenuOpen = useState(false)
	local isHelpMenuOpen, setIsHelpMenuOpen = useState(false)

	local navigation = NavigationContext.use()
	local storyActions = StoryActionsContext.useStoryActions()
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local onThemeChanged = useCallback(function(itemId: ItemId)
		userSettingsStore.setStorage(function(currentValue)
			return Object.assign({}, currentValue, {
				theme = itemId,
			})
		end)
	end, { userSettingsStore.setStorage })

	return e(
		View,
		withCommonProps(props, {
			tag = "align-y-center auto-y bg-surface-0 flex-x-between padding-right-medium padding-y-medium row size-full-0",
		}),
		{
			Actions = e(View, {
				LayoutOrder = 1,
				tag = "align-y-center auto-y gap-medium row shrink size-full-0",
			}, {
				Zoom = e(View, {
					LayoutOrder = 1,
					tag = "auto-xy row",
				}, {
					ZoomIn = e(Tooltip, {
						LayoutOrder = 1,
						align = PopoverAlign.Center,
						side = PopoverSide.Bottom,
						title = "Zoom In",
					}, {
						Trigger = e(IconButton, {
							icon = IconName.MagnifyingGlassPlus,
							isDisabled = storyActions.isDisabled,
							onActivated = storyActions.zoom.zoomIn,
						}),
					}),

					ZoomOut = e(Tooltip, {
						LayoutOrder = 2,
						align = PopoverAlign.Center,
						side = PopoverSide.Bottom,
						title = "Zoom Out",
					}, {
						Trigger = e(IconButton, {
							icon = IconName.MagnifyingGlassMinus,
							isDisabled = storyActions.isDisabled,
							onActivated = storyActions.zoom.zoomOut,
						}),
					}),
				}),

				ZoomDivider = e(Divider, {
					LayoutOrder = 2,
					orientation = Orientation.Vertical,
				}),

				Views = e(View, {
					LayoutOrder = 3,
					tag = "auto-xy row",
				}, {
					Source = e(Tooltip, {
						LayoutOrder = 1,
						align = PopoverAlign.Center,
						side = PopoverSide.Bottom,
						title = "View Source Code",
					}, {
						Trigger = e(IconButton, {
							icon = IconName.Code,
							isDisabled = storyActions.isDisabled,
							onActivated = storyActions.viewCode,
						}),
					}),

					Viewport = e(Tooltip, {
						LayoutOrder = 2,
						align = PopoverAlign.Center,
						side = PopoverSide.Bottom,
						title = "Preview in Viewport",
					}, {
						Trigger = e(IconButton, {
							icon = IconName.Eye,
							isDisabled = storyActions.isDisabled,
							onActivated = storyActions.viewportPreview,
						}),
					}),

					Explorer = e(Tooltip, {
						LayoutOrder = 3,
						align = PopoverAlign.Center,
						side = PopoverSide.Bottom,
						title = "View in Explorer",
					}, {
						Trigger = e(IconButton, {
							icon = IconName.MagnifyingGlass,
							isDisabled = storyActions.isDisabled,
							onActivated = storyActions.viewExplorer,
						}),
					}),
				}),

				ViewsDivider = e(Divider, {
					LayoutOrder = 4,
					orientation = Orientation.Vertical,
				}),

				Theme = e(Dropdown.Root, {
					LayoutOrder = 5,
					items = {
						{ id = "system", text = "System" },
						{ id = "dark", text = "Dark" },
						{ id = "light", text = "Light" },
					},
					label = "",
					onItemChanged = onThemeChanged,
					placeholder = "Theme",
					size = InputSize.Small,
					value = userSettings.theme,
					width = UDim.new(0, 160),
				}),
			}),

			Support = e(View, {
				LayoutOrder = 2,
				tag = "auto-xy row",
			}, {
				Help = e(Tooltip, {
					LayoutOrder = 1,
					align = PopoverAlign.Center,
					side = PopoverSide.Bottom,
					title = "Help",
				}, {
					Trigger = e(IconButton, {
						icon = IconName.CircleQuestion,
						onActivated = function()
							setIsHelpMenuOpen(true)
						end,
						ref = helpButtonRef,
					}),
				}),

				Settings = e(Tooltip, {
					LayoutOrder = 2,
					align = PopoverAlign.End,
					side = PopoverSide.Bottom,
					title = "Settings",
				}, {
					Trigger = e(IconButton, {
						icon = {
							name = IconName.Gear,
							variant = if navigation.currentScreen == "Settings"
								then IconVariant.Filled
								else IconVariant.Regular,
						},
						onActivated = function()
							if navigation.currentScreen ~= "Settings" then
								navigation.navigateTo("Settings")
							else
								navigation.navigateTo("Home")
							end
						end,
					}),
				}),
			}),

			AboutMenu = isAboutMenuOpen and e(Dialog.Root, {
				disablePortal = false,
				hasBackdrop = true,
				onClose = function()
					setIsAboutMenuOpen(false)
				end,
			}, {
				Title = e(Dialog.Title, {
					text = "About",
				}),

				Content = e(Dialog.Content, nil, {
					View = e(AboutView),
				}),
			}),

			HelpMenu = e(Menu, {
				anchorRef = helpButtonRef,
				isOpen = isHelpMenuOpen,
				items = {
					{
						id = "About",
						text = "About",
						onActivated = function()
							setIsAboutMenuOpen(true)
							setIsHelpMenuOpen(false)
						end,
					},
				},
				onPressedOutside = function()
					setIsHelpMenuOpen(function(currentValue)
						return not currentValue
					end)
				end,
			}),
		}
	)
end

return React.memo(Topbar)
