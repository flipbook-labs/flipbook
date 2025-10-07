local React = require(script.Parent.Parent.Packages.React)
local SignalsReact = require(script.Parent.Parent.RobloxPackages.SignalsReact)

local UserSettingsStore = require(script.Parent.Parent.UserSettings.UserSettingsStore)

local useMemo = React.useMemo
local useState = React.useState
local useEffect = React.useEffect
local useSignalState = SignalsReact.useSignalState

type ThemeName = "Dark" | "Light"

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

	useEffect(function(): any
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
