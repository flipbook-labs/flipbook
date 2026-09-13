local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")

local LocalStorageStore = require("@root/Plugin/LocalStorageStore")
local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local getInstanceFromPath = require("@root/Common/getInstanceFromPath")
local getInstancePath = require("@root/Common/getInstancePath")

local useCallback = React.useCallback
local useMemo = React.useMemo
local useSignalState = ReactCharm.useSignalState

export type LastOpenedStory = {
	storyId: string?,
	storyModule: ModuleScript,
	storybookSource: ModuleScript?,
}

local function useLastOpenedStory(): (LastOpenedStory?, (
	storyModule: ModuleScript?,
	storybookSource: ModuleScript?,
	storyId: string?
) -> ())
	local localStorageStore = useSignalState(LocalStorageStore.get)
	local localStorage = useSignalState(localStorageStore.getStorage)

	local userSettingsStore = useSignalState(UserSettingsStore.get)
	local userSettings = useSignalState(userSettingsStore.getStorage)

	local setLastOpenedStory = useCallback(
		function(storyModule: ModuleScript?, storybookSource: ModuleScript?, storyId: string?)
			localStorageStore.setStorage(function(prev)
				local nextStorage = table.clone(prev)
				nextStorage.lastOpenedStoryId = if storyModule then storyId else nil
				nextStorage.lastOpenedStoryPath = if storyModule then getInstancePath(storyModule) else nil
				nextStorage.lastOpenedStorybookPath = if storyModule and storybookSource
					then getInstancePath(storybookSource)
					else nil
				return nextStorage
			end)
		end,
		{ localStorageStore }
	)

	local lastOpenedStory = useMemo(function(): LastOpenedStory?
		local rememberLastOpenedStory = userSettings.rememberLastOpenedStory

		if not rememberLastOpenedStory then
			return nil
		end

		local lastOpenedStoryPath = localStorage.lastOpenedStoryPath

		if lastOpenedStoryPath then
			local instance = getInstanceFromPath(lastOpenedStoryPath)
			local storybookSource
			if localStorage.lastOpenedStorybookPath then
				local storedStorybook = getInstanceFromPath(localStorage.lastOpenedStorybookPath)
				if storedStorybook and storedStorybook:IsA("ModuleScript") then
					storybookSource = storedStorybook
				end
			end

			if instance and instance:IsA("ModuleScript") then
				return {
					storyId = localStorage.lastOpenedStoryId,
					storyModule = instance,
					storybookSource = storybookSource,
				}
			end
		end

		return nil
	end, { userSettings, localStorage } :: { unknown })

	return lastOpenedStory, setLastOpenedStory
end

return useLastOpenedStory
