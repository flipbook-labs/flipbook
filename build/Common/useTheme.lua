local React = require(script.Parent.Parent.Packages.React)
local SignalsReact = require(script.Parent.Parent.RobloxPackages.SignalsReact)

local UserSettingsStore = require(script.Parent.Parent.UserSettings.UserSettingsStore)
local themes = require(script.Parent.Parent.themes)
local usePrevious = require(script.Parent.usePrevious)

local useMemo = React.useMemo
local useState = React.useState
local useEffect = React.useEffect
local useSignalState = SignalsReact.useSignalState

local MOCK_STUDIO = {
	ThemeChanged = Instance.new("BindableEvent").Event,
	Theme = {
		Name = "Light",
	},
}

local function useTheme()
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local themeOverride = userSettings.theme
	local prevThemeOverride = usePrevious(themeOverride)

	local studio: Studio = useMemo(function()
		local success, result = pcall(function()
			return (settings() :: any).Studio
		end)

		return if success then result else MOCK_STUDIO
	end, {})

	local themeName = useMemo(function()
		if themeOverride ~= "system" then
			if themeOverride == "dark" then
				return "Dark"
			elseif themeOverride == "light" then
				return "Light"
			end
		end
		return studio.Theme.Name
	end, { themeOverride, studio } :: { unknown })

	local theme: themes.Theme, set = useState(themes[themeName])

	useEffect(function()
		if themeOverride ~= prevThemeOverride then
			set(themes[themeName])
		end
	end, { themeOverride, prevThemeOverride, themeName } :: { unknown })

	useEffect(function(): any
		if themeOverride == "system" then
			local conn = studio.ThemeChanged:Connect(function()
				set(themes[studio.Theme.Name])
			end)

			return function()
				conn:Disconnect()
			end
		else
			return nil
		end
	end, { themeOverride })

	return theme
end

return useTheme
