local React = require("@pkg/React")

local PluginContext = require("@root/Plugin/PluginContext")
local SettingsContext = require("@root/UserSettings/SettingsContext")
local getInstanceFromFullName = require("@root/Common/getInstanceFromFullName")

local useContext = React.useContext
local useCallback = React.useCallback
local useMemo = React.useMemo

local function useLastOpenedStory(): (ModuleScript?, (storyModule: ModuleScript?) -> ())
	local plugin = useContext(PluginContext.Context)

	local settingsContext = SettingsContext.use()
	local rememberLastOpenedStory = settingsContext.getSetting("rememberLastOpenedStory")

	local setLastOpenedStory = useCallback(function(storyModule: ModuleScript?)
		plugin:SetSetting("lastOpenedStoryPath", if storyModule then storyModule:GetFullName() else nil)
	end, { plugin })

	local lastOpenedStory = useMemo(function(): ModuleScript?
		if not rememberLastOpenedStory then
			return nil
		end

		local lastOpenedStoryPath = plugin:GetSetting("lastOpenedStoryPath")

		if lastOpenedStoryPath then
			local instance = getInstanceFromFullName(lastOpenedStoryPath)

			if instance and instance:IsA("ModuleScript") then
				return instance
			end
		end

		return nil
	end, { rememberLastOpenedStory, plugin })

	return lastOpenedStory, setLastOpenedStory
end

return useLastOpenedStory
