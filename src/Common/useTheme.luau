local React = require("@pkg/react")

local SettingsContext = require("@root/UserSettings/SettingsContext")
local themes = require("@root/themes")
local usePrevious = require("@root/Common/usePrevious")

local useMemo = React.useMemo
local useState = React.useState
local useEffect = React.useEffect

local MOCK_STUDIO = {
	ThemeChanged = Instance.new("BindableEvent").Event,
	Theme = {
		Name = "Light",
	},
}

local function useTheme()
	local settingsContext = SettingsContext.use()

	local themeOverride = settingsContext.getSetting("theme")
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
	end, { themeOverride, studio })

	local theme: themes.Theme, set = useState(themes[themeName])

	useEffect(function()
		if themeOverride ~= prevThemeOverride then
			set(themes[themeName])
		end
	end, { themeOverride, prevThemeOverride, themeName })

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
