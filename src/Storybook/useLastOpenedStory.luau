local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local SignalsReact = require("@rbxpkg/SignalsReact")

local PluginSettingsStore = require("@root/Plugin/PluginSettingsStore")
local SettingsContext = require("@root/UserSettings/SettingsContext")
local getInstanceFromFullName = require("@root/Common/getInstanceFromFullName")

local useCallback = React.useCallback
local useMemo = React.useMemo
local useSignalState = SignalsReact.useSignalState

local REMEMBER_LAST_OPENED_STORY_KEY = "rememberLastOpenedStory"

local function useLastOpenedStory(): (ModuleScript?, (storyModule: ModuleScript?) -> ())
	local pluginSettingsStore = useSignalState(PluginSettingsStore.get)
	local settingsContext = SettingsContext.use()

	local setLastOpenedStory = useCallback(function(storyModule: ModuleScript?)
		pluginSettingsStore.set(function(prev)
			return Sift.Dictionary.join(prev, {
				lastOpenedStoryPath = if storyModule then storyModule:GetFullName() else nil,
			})
		end)
	end, { pluginSettingsStore })

	local lastOpenedStory = useMemo(function(): ModuleScript?
		local rememberLastOpenedStory = settingsContext.getSetting(REMEMBER_LAST_OPENED_STORY_KEY)

		if not rememberLastOpenedStory then
			return nil
		end

		local lastOpenedStoryPath = pluginSettingsStore.get(false).lastOpenedStoryPath

		if lastOpenedStoryPath and typeof(lastOpenedStoryPath) == "string" then
			local instance = getInstanceFromFullName(lastOpenedStoryPath)

			if instance and instance:IsA("ModuleScript") then
				return instance
			end
		end

		return nil
	end, { settingsContext, pluginSettingsStore } :: { unknown })

	return lastOpenedStory, setLastOpenedStory
end

return useLastOpenedStory
