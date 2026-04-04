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

-- Language codes copied from:
-- https://create.roblox.com/docs/production/localization/language-codes
local ROBLOX_SUPPORTED_LANGUAGES = {
	"ar-001",
	"bg-bg",
	"bn-bd",
	"bs-ba",
	"cs-cz",
	"da-dk",
	"de-de",
	"el-gr",
	"en-gb",
	"en-us",
	"es-es",
	"es-mx",
	"et-ee",
	"fi-fi",
	"fil-ph",
	"fr-ca",
	"fr-fr",
	"hi-in",
	"hr-hr",
	"hu-hu",
	"id-id",
	"it-it",
	"ja-jp",
	"ka-ge",
	"kk-kz",
	"km-kh",
	"ko-kr",
	"lt-lt",
	"lv-lv",
	"ms-my",
	"my-mm",
	"nb-no",
	"nl-nl",
	"pl-pl",
	"pt-br",
	"pt-pt",
	"ro-ro",
	"ru-ru",
	"si-lk",
	"sk-sk",
	"sl-sl",
	"sq-al",
	"sr-rs",
	"sv-se",
	"th-th",
	"tr-tr",
	"uk-ua",
	"vi-vn",
	"zh-cn",
	"zh-tw",
}

export type Props = {
	LayoutOrder: number?,
}

local function LocaleSwitcher(props: Props)
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local locales = React.useMemo(function()
		return Sift.List.map(ROBLOX_SUPPORTED_LANGUAGES, function(locale): { id: string, text: string }
			return {
				id = locale,
				text = locale,
			}
		end)
	end, {})

	local onLocaleChanged = useCallback(function(itemId: ItemId)
		userSettingsStore.setStorage(function(currentValue)
			return Sift.Dictionary.join(currentValue, {
				locale = itemId,
			})
		end)
	end, { userSettingsStore.setStorage })

	return e(Dropdown.Root, {
		LayoutOrder = props.LayoutOrder,
		items = locales,
		label = "",
		onItemChanged = onLocaleChanged,
		placeholder = "Locale",
		size = InputSize.Small,
		value = userSettings.locale,
		width = UDim.new(0, 160),
		maxHeight = 300,
	})
end

return LocaleSwitcher
