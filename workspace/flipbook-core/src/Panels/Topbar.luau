local Foundation = require("@rbxpkg/Foundation")
local LuauPolyfill = require("@pkg/LuauPolyfill")
local React = require("@pkg/React")
local ReactSignals = require("@pkg/ReactCharm")

local AboutView = require("@root/About/AboutView")
local AppMode = require("@root/Enums/AppMode")
local EmbedIntoExperienceDialog = require("@root/Embedding/EmbedIntoExperienceDialog")
local FeedbackDialog = require("@root/Feedback/FeedbackDialog")
local NavigationStore = require("@root/Navigation/NavigationStore")
local StoryStore = require("@root/Storybook/StoryStore")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")

local Object = LuauPolyfill.Object

local Badge = Foundation.Badge
local Dialog = Foundation.Dialog
local Divider = Foundation.Divider
local Dropdown = Foundation.Dropdown
local IconButton = Foundation.IconButton
local IconName = Foundation.Enums.IconName
local IconPosition = Foundation.Enums.IconPosition
local IconVariant = Foundation.Enums.IconVariant
local InputSize = Foundation.Enums.InputSize
local Menu = Foundation.Menu
local Orientation = Foundation.Enums.Orientation
local PopoverAlign = Foundation.Enums.PopoverAlign
local PopoverSide = Foundation.Enums.PopoverSide
local Tooltip = Foundation.Tooltip
local View = Foundation.View
local ScrollView = Foundation.ScrollView
local withCommonProps = Foundation.Utility.withCommonProps

local useTokens = Foundation.Hooks.useTokens

local e = React.createElement
local useCallback = React.useCallback
local useRef = React.useRef
local useState = React.useState

local useSignalState = ReactSignals.useSignalState

type ItemId = number | string

type TopbarProps = {
	showDevBadge: boolean?,
	showBetaBadge: boolean?,
	showInternalBadge: boolean?,
} & Foundation.CommonProps

local function Topbar(props: TopbarProps)
	local helpButtonRef = useRef(nil :: GuiObject?)

	local tokens = useTokens()

	local isAboutMenuOpen, setIsAboutMenuOpen = useState(false)
	local isEmbedDialogOpen, setIsEmbedDialogOpen = useState(false)
	local isHelpMenuOpen, setIsHelpMenuOpen = useState(false)
	local isFeedbackDialogOpen, setIsFeedbackDialogOpen = useState(false)

	local navigationStore = useSignalState(NavigationStore.get)
	local currentScreen = useSignalState(navigationStore.getCurrentScreen)
	local storyStore = useSignalState(StoryStore.get)
	local isStoryActionsDisabled = useSignalState(storyStore.getIsStoryActionsDisabled)
	local storyMode = useSignalState(storyStore.getMode)
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local hasBadges = props.showDevBadge or props.showBetaBadge or props.showInternalBadge

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
			tag = "align-y-center bg-surface-0 flex-x-between padding-right-medium padding-y-medium row gap-large size-full-1400",
		}),
		{
			Actions = e(ScrollView, {
				LayoutOrder = 1,
				tag = "size-full shrink",
				scroll = {
					ScrollingDirection = Enum.ScrollingDirection.X,
					AutomaticCanvasSize = Enum.AutomaticSize.X,
					CanvasSize = UDim2.fromScale(0, 0),
				},
				layout = {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, tokens.Padding.Medium),
				},
			}, {
				Zoom = e(View, {
					LayoutOrder = 1,
					tag = "auto-x row size-0-full",
				}, {
					ZoomIn = e(Tooltip, {
						LayoutOrder = 1,
						align = PopoverAlign.Center,
						side = PopoverSide.Bottom,
						title = "Zoom In",
					}, {
						Trigger = e(IconButton, {
							icon = IconName.MagnifyingGlassPlus,
							isDisabled = isStoryActionsDisabled,
							onActivated = storyStore.zoomIn,
							size = InputSize.Small,
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
							isDisabled = isStoryActionsDisabled,
							onActivated = storyStore.zoomOut,
							size = InputSize.Small,
						}),
					}),
				}),

				ZoomDivider = e(Divider, {
					LayoutOrder = 2,
					orientation = Orientation.Vertical,
				}),

				Views = e(View, {
					LayoutOrder = 3,
					tag = "auto-x row size-0-full",
				}, {
					Source = e(Tooltip, {
						LayoutOrder = 1,
						align = PopoverAlign.Center,
						side = PopoverSide.Bottom,
						title = "View Source Code",
					}, {
						Trigger = e(IconButton, {
							icon = IconName.Code,
							isDisabled = isStoryActionsDisabled,
							onActivated = storyStore.viewCode,
							size = InputSize.Small,
						}),
					}),

					Viewport = storyMode == AppMode.PluginWidget and e(Tooltip, {
						LayoutOrder = 2,
						align = PopoverAlign.Center,
						side = PopoverSide.Bottom,
						title = "Preview in Viewport",
					}, {
						Trigger = e(IconButton, {
							icon = IconName.Eye,
							isDisabled = isStoryActionsDisabled,
							onActivated = storyStore.viewportPreview,
							size = InputSize.Small,
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
							isDisabled = isStoryActionsDisabled,
							onActivated = storyStore.viewExplorer,
							size = InputSize.Small,
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
				tag = "auto-x row size-0-full gap-small align-y-center",
			}, {
				BadgeCluster = hasBadges and e(View, {
					LayoutOrder = 1,
					tag = "auto-xy row gap-xsmall",
				}, {
					DevBadge = if props.showDevBadge
						then e(Badge, {
							LayoutOrder = 1,
							text = "Development",
							icon = IconName.Code,
							variant = Foundation.Enums.BadgeVariant.Neutral,
							size = Foundation.Enums.InputSize.Small,
						})
						else nil,

					BetaBadge = if props.showBetaBadge
						then e(Badge, {
							LayoutOrder = 2,
							text = "Beta",
							icon = {
								name = IconName.LabBeaker,
								variant = IconVariant.Filled,
								position = IconPosition.Left,
							},
							variant = Foundation.Enums.BadgeVariant.Contrast,
							size = Foundation.Enums.InputSize.Small,
						})
						else nil,

					InternalBadge = if props.showInternalBadge
						then e(Badge, {
							LayoutOrder = 3,
							text = "Internal",
							icon = IconName.Tilt,
							variant = Foundation.Enums.BadgeVariant.Contrast,
							size = Foundation.Enums.InputSize.Small,
						})
						else nil,
				}),

				SupportCluster = e(View, {
					LayoutOrder = 2,
					tag = "auto-xy row gap-xsmall",
				}, {
					EmbedIntoExperience = storyMode ~= AppMode.EmbeddedClient and e(Tooltip, {
						LayoutOrder = 1,
						align = PopoverAlign.Center,
						side = PopoverSide.Bottom,
						title = "Embed into Experience",
					}, {
						Trigger = e(IconButton, {
							icon = IconName.SquareBooks,
							onActivated = function()
								setIsEmbedDialogOpen(true)
							end,
							size = InputSize.Small,
						}),
					}),

					Help = e(Tooltip, {
						LayoutOrder = 2,
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
							size = InputSize.Small,
						}),
					}),

					Settings = e(Tooltip, {
						LayoutOrder = 3,
						align = PopoverAlign.End,
						side = PopoverSide.Bottom,
						title = "Settings",
					}, {
						Trigger = e(IconButton, {
							icon = {
								name = IconName.Gear,
								variant = if currentScreen == "Settings"
									then IconVariant.Filled
									else IconVariant.Regular,
							},
							onActivated = function()
								if currentScreen ~= "Settings" then
									navigationStore.navigateTo("Settings")
								else
									navigationStore.navigateTo("Home")
								end
							end,
							size = InputSize.Small,
						}),
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

			EmbedIntoExperienceDialog = if isEmbedDialogOpen
				then e(EmbedIntoExperienceDialog, {
					onClose = function()
						setIsEmbedDialogOpen(false)
					end,
				})
				else nil,

			FeedbackDialog = if isFeedbackDialogOpen
				then React.createElement(FeedbackDialog, {
					onClose = function()
						setIsFeedbackDialogOpen(false)
					end,
				})
				else nil,

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
					{
						id = "Feedback",
						text = "Send feedback",
						onActivated = function()
							setIsFeedbackDialogOpen(true)
							setIsHelpMenuOpen(false)
						end,
					},
					{
						id = "Logs",
						text = "Logs",
						onActivated = function()
							if currentScreen ~= "Settings" then
								navigationStore.navigateTo("Logs")
							else
								navigationStore.navigateTo("Home")
							end
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
