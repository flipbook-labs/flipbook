local React = require("@pkg/React")
local ReactCharm = require("@pkg/ReactCharm")

local AboutView = require("@root/About/AboutView")
local FlipbookStoreContext = require("@root/FlipbookStore/FlipbookStoreContext")
local LogsView = require("@root/Logs/LogsView")
local NoStorySelected = require("@root/Storybook/NoStorySelected")
local SettingsView = require("@root/UserSettings/SettingsView")
local StorySelectionKind = require("@root/Storybook/StorySelectionKind")
local StoryView = require("@root/Storybook/StoryView")
local StorybookError = require("@root/Storybook/StorybookError")

local useMemo = React.useMemo
local useSignalState = ReactCharm.useSignalState

local function Screen()
	local flipbookStore = FlipbookStoreContext.use()
	local currentScreen = useSignalState(flipbookStore.navigation.getCurrentScreen)
	local storySelectionKind = useSignalState(flipbookStore.story.getSelectionKind)
	local unavailableStorybook = useSignalState(flipbookStore.story.getUnavailableStorybook)

	local screenElement = useMemo(function(): React.Node
		if currentScreen == "Home" then
			if storySelectionKind == StorySelectionKind.Story then
				return React.createElement(StoryView)
			elseif storySelectionKind == StorySelectionKind.UnavailableStorybook and unavailableStorybook then
				return React.createElement(StorybookError, {
					unavailableStorybook = unavailableStorybook,
				})
			else
				return React.createElement(NoStorySelected)
			end
		elseif currentScreen == "Settings" then
			return React.createElement(SettingsView)
		elseif currentScreen == "About" then
			return React.createElement(AboutView)
		elseif currentScreen == "Logs" then
			return React.createElement(LogsView)
		end
		return nil :: never
	end, { currentScreen, storySelectionKind, unavailableStorybook } :: { unknown })

	return screenElement
end

return Screen
