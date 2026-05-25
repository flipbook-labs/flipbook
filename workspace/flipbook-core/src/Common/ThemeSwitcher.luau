local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")
local Sift = require("@pkg/Sift")

local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")

local Dropdown = Foundation.Dropdown
local InputSize = Foundation.Enums.InputSize

local e = React.createElement
local useCallback = React.useCallback

local useSignalState = ReactCharm.useSignalState

type ItemId = number | string

export type Props = {
	LayoutOrder: number?,
}

local function ThemeSwitcher(props: Props)
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local onThemeChanged = useCallback(function(itemId: ItemId)
		userSettingsStore.setStorage(function(currentValue)
			return Sift.Dictionary.join(currentValue, {
				theme = itemId,
			})
		end)
	end, { userSettingsStore.setStorage })

	return e(Dropdown.Root, {
		LayoutOrder = props.LayoutOrder,
		items = {
			{ id = "system", text = "System" },
			{ id = "dark", text = "Dark" },
			{ id = "light", text = "Light" },
		},
		label = "",
		onItemChanged = onThemeChanged,
		size = InputSize.Small,
		value = userSettings.theme,
		width = UDim.new(0, 160),
		maxHeight = 300,
	})
end

return ThemeSwitcher
