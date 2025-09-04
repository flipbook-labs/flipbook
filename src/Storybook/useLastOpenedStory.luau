local React = require("@pkg/React")

local LocalStorageContext = require("@root/Plugin/LocalStorageContext")
local SettingsContext = require("@root/UserSettings/SettingsContext")
local getInstanceFromFullName = require("@root/Common/getInstanceFromFullName")

local useCallback = React.useCallback
local useMemo = React.useMemo

local REMEMBER_LAST_OPENED_STORY_KEY = "rememberLastOpenedStory"
local LAST_OPENED_STORY_PATH_KEY = "lastOpenedStoryPath"

local function useLastOpenedStory(): (ModuleScript?, (storyModule: ModuleScript?) -> ())
	local localStorage = LocalStorageContext.use()
	local settingsContext = SettingsContext.use()

	local setLastOpenedStory = useCallback(function(storyModule: ModuleScript?)
		localStorage.set(LAST_OPENED_STORY_PATH_KEY, if storyModule then storyModule:GetFullName() else nil)
	end, { localStorage })

	local lastOpenedStory = useMemo(function(): ModuleScript?
		local rememberLastOpenedStory = settingsContext.getSetting(REMEMBER_LAST_OPENED_STORY_KEY)

		if not rememberLastOpenedStory then
			return nil
		end

		local lastOpenedStoryPath = localStorage.get(LAST_OPENED_STORY_PATH_KEY)

		if lastOpenedStoryPath and typeof(lastOpenedStoryPath) == "string" then
			local instance = getInstanceFromFullName(lastOpenedStoryPath)

			if instance and instance:IsA("ModuleScript") then
				return instance
			end
		end

		return nil
	end, { settingsContext, localStorage } :: { unknown })

	return lastOpenedStory, setLastOpenedStory
end

return useLastOpenedStory
