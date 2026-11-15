local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")

local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")

local useMemo = React.useMemo
local useState = React.useState
local useEffect = React.useEffect
local useSignalState = ReactCharm.useSignalState

export type ThemeName = "Dark" | "Light"

local MOCK_STUDIO = {
	ThemeChanged = Instance.new("BindableEvent").Event,
	Theme = {
		Name = "Light",
	},
}

local function useThemeName(): ThemeName
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local studio: Studio = useMemo(function()
		local success, result = pcall(function()
			-- MOCK_STUDIO stands in for Studio when settings() isn't available,
			-- and the cast lets both share the Studio type.
			-- lute-lint-ignore(no_any)
			return (settings() :: any).Studio
		end)

		return if success then result else MOCK_STUDIO
	end, {})

	local studioTheme, setStudioTheme = useState(studio.Theme.Name)

	local theme = useMemo(function(): ThemeName
		if userSettings.theme ~= "system" then
			if userSettings.theme == "dark" then
				return "Dark"
			elseif userSettings.theme == "light" then
				return "Light"
			end
		else
			if studioTheme == "Dark" or studioTheme == "Light" then
				return studioTheme
			end
		end
		return "Dark"
	end, { userSettings.theme, studioTheme } :: { unknown })

	useEffect(function(): unknown
		local conn = studio.ThemeChanged:Connect(function()
			setStudioTheme(studio.Theme.Name)
		end)

		return function()
			conn:Disconnect()
		end
	end, { studio })

	return theme :: ThemeName
end

return useThemeName
