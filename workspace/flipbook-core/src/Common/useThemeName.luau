local Foundation = require("@rbxpkg/Foundation")
local ReactCharm = require("@pkg/ReactCharm")

local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")

local useSignalState = ReactCharm.useSignalState

local function useThemeName(): Foundation.ThemeName
	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	return userSettings.themeName :: Foundation.ThemeName
end

return useThemeName
