local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local SignalsReact = require("@rbxpkg/SignalsReact")

local LocalStorageStore = require("@root/Plugin/LocalStorageStore")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local getInstanceFromPath = require("@root/Common/getInstanceFromPath")

local useCallback = React.useCallback
local useMemo = React.useMemo
local useSignalState = SignalsReact.useSignalState

local function useLastOpenedStory(): (ModuleScript?, (storyModule: ModuleScript?) -> ())
	local localStorageStore = useSignalState(LocalStorageStore.get)
	local localStorage = useSignalState(localStorageStore.getStorage)

	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local setLastOpenedStory = useCallback(function(storyModule: ModuleScript?)
		localStorageStore.setStorage(function(prev)
			return Sift.Dictionary.join(prev, {
				lastOpenedStoryPath = if storyModule then storyModule:GetFullName() else nil,
			})
		end)
	end, { localStorageStore })

	local lastOpenedStory = useMemo(function(): ModuleScript?
		local rememberLastOpenedStory = userSettings.rememberLastOpenedStory

		if not rememberLastOpenedStory then
			return nil
		end

		local lastOpenedStoryPath = localStorage.lastOpenedStoryPath

		if lastOpenedStoryPath and typeof(lastOpenedStoryPath) == "string" then
			local instance = getInstanceFromPath(lastOpenedStoryPath)

			if instance and instance:IsA("ModuleScript") then
				return instance
			end
		end

		return nil
	end, { localStorage, localStorageStore } :: { unknown })

	return lastOpenedStory, setLastOpenedStory
end

return useLastOpenedStory
