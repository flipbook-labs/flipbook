local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local Button = require("@root/Forms/Button")
local Modal = require("@root/Modal/Modal")
local ModalPortal = require("@root/Modal/ModalPortal")
local ScrollingFrame = require("@root/Common/ScrollingFrame")
local SettingRow = require("@root/UserSettings/SettingRow")
local SettingsContext = require("@root/UserSettings/SettingsContext")
local defaultSettings = require("@root/UserSettings/defaultSettings")
local nextLayoutOrder = require("@root/Common/nextLayoutOrder")
local useTheme = require("@root/Common/useTheme")

local useMemo = React.useMemo

type Setting = defaultSettings.Setting
type SettingChoice = defaultSettings.SettingChoice

local function SettingsView()
	local settingsContext = SettingsContext.use()
	local theme = useTheme()

	local isConfirmationShown, setIsConfirmationShown = React.useState(false)

	local toggleConfirmationModal = React.useCallback(function()
		setIsConfirmationShown(function(prev)
			return not prev
		end)
	end, {})

	local confirmSettingsReset = React.useCallback(function()
		toggleConfirmationModal()
		settingsContext.resetAllSettings()
	end, { settingsContext.resetAllSettings })

	local orderedSettings: { Setting } = useMemo(function()
		local values = Sift.Dictionary.values(settingsContext.settings)
		return Sift.Array.sort(values, function(a: Setting, b: Setting)
			return a.name < b.name
		end)
	end, { settingsContext.settings })

	local children = {}
	for index, setting in orderedSettings do
		children[setting.name] = React.createElement(SettingRow, {
			setting = setting,
			layoutOrder = index,
		})
	end

	return React.createElement(ScrollingFrame, {
		BackgroundColor3 = theme.background,
		BackgroundTransparency = 0,
	}, {
		Layout = React.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		Header = React.createElement("Frame", {
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			Title = React.createElement("TextLabel", {
				LayoutOrder = nextLayoutOrder(),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Font = theme.headerFont,
				Text = "Settings",
				TextColor3 = theme.text,
				TextSize = theme.headerTextSize,
			}, {
				Padding = React.createElement("UIPadding", {
					PaddingTop = theme.paddingLarge,
					PaddingRight = theme.paddingLarge,
					PaddingBottom = theme.paddingLarge,
					PaddingLeft = theme.paddingLarge,
				}),
			}),

			ResetSettings = React.createElement(Button, {
				layoutOrder = nextLayoutOrder(),
				text = "Reset settings",
				onClick = toggleConfirmationModal,
			}),
		}),

		ResetSettingsConfirmation = if isConfirmationShown
			then React.createElement(ModalPortal, {}, {
				Modal = React.createElement(Modal, {
					title = "Reset settings",
					onClose = toggleConfirmationModal,
				}, {
					Layout = React.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = theme.paddingLarge,
					}),

					FinalWarning = React.createElement("TextLabel", {
						LayoutOrder = nextLayoutOrder(),
						Text = "This will reset your settings for flipbook to the defaults. This action cannot be undone.\n\nAre you sure you want to reset all plugin settings?",
						AutomaticSize = Enum.AutomaticSize.XY,
						Font = theme.font,
						BackgroundTransparency = 1,
						TextWrapped = true,
						TextColor3 = theme.text,
						TextSize = theme.textSize,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}),

					ButtonCluster = React.createElement("Frame", {
						LayoutOrder = nextLayoutOrder(),
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
					}, {
						Layout = React.createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = theme.padding,
						}),

						Cancel = React.createElement(Button, {
							layoutOrder = nextLayoutOrder(),
							text = "Cancel",
							onClick = toggleConfirmationModal,
						}),

						Confirm = React.createElement(Button, {
							layoutOrder = nextLayoutOrder(),
							text = "Reset to defaults",
							backgroundColor = theme.alert,
							textColor = theme.text,
							onClick = confirmSettingsReset,
						}),
					}),
				}),
			})
			else nil,

		Settings = React.createElement("Frame", {
			LayoutOrder = nextLayoutOrder(),
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			Layout = React.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = theme.padding,
			}),
		}, children),
	})
end

return SettingsView
