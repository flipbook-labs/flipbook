local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")

local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")

local useMemo = React.useMemo
local useState = React.useState
local useEffect = React.useEffect
local useSignalState = ReactCharm.useSignalState

export type ColorMode = "Dark" | "Light"

local MOCK_STUDIO = {
	ThemeChanged = Instance.new("BindableEvent").Event,
	Theme = {
		Name = "Light",
	},
}

local function useColorMode(): ColorMode
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local studio: Studio = useMemo(function()
		local success, result = pcall(function()
			return (settings() :: any).Studio
		end)

		return if success then result else MOCK_STUDIO
	end, {})

	local studioTheme, setStudioTheme = useState(studio.Theme.Name)

	local colorMode = useMemo(function(): ColorMode
		if userSettings.colorMode ~= "system" then
			if userSettings.colorMode == "dark" then
				return "Dark"
			elseif userSettings.colorMode == "light" then
				return "Light"
			end
		else
			if studioTheme == "Dark" or studioTheme == "Light" then
				return studioTheme
			end
		end
		return "Dark"
	end, { userSettings.colorMode, studioTheme } :: { unknown })

	useEffect(function(): any
		local conn = studio.ThemeChanged:Connect(function()
			setStudioTheme(studio.Theme.Name)
		end)

		return function()
			conn:Disconnect()
		end
	end, { studio })

	return colorMode :: ColorMode
end

return useColorMode
