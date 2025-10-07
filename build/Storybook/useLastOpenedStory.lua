local React = require(script.Parent.Parent.Packages.React)
local Sift = require(script.Parent.Parent.Packages.Sift)
local SignalsReact = require(script.Parent.Parent.RobloxPackages.SignalsReact)

local LocalStorageStore = require(script.Parent.Parent.Plugin.LocalStorageStore)
local UserSettingsStore = require(script.Parent.Parent.UserSettings.UserSettingsStore)
local getInstanceFromFullName = require(script.Parent.Parent.Common.getInstanceFromFullName)

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

		if lastOpenedStoryPath then
			local instance = getInstanceFromFullName(lastOpenedStoryPath)

			if instance and instance:IsA("ModuleScript") then
				return instance
			end
		end

		return nil
	end, { localStorage, localStorageStore } :: { unknown })

	return lastOpenedStory, setLastOpenedStory
end

return useLastOpenedStory
