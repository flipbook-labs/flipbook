local React = require("@pkg/React")
local SignalsReact = require("@rbxpkg/SignalsReact")
local Storyteller = require("@pkg/Storyteller")

local AboutView = require("@root/About/AboutView")
local NavigationContext = require("@root/Navigation/NavigationContext")
local NoStorySelected = require("@root/Storybook/NoStorySelected")
local SettingsView = require("@root/UserSettings/SettingsView")
local StoryCanvas = require("@root/Storybook/StoryCanvas")
local StorybookError = require("@root/Storybook/StorybookError")

local useSignalState = SignalsReact.useSignalState

local useMemo = React.useMemo

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

local function Screen()
	local navigation = NavigationContext.use()
	local currentScreen = navigation.currentScreen

	local flipbookStore = useSignalState(FlipbookStore.get)
	local activeStory = useSignalState(flipbookStore.getActiveStory)
	local activeStorybook = useSignalState(flipbookStore.getActiveStorybook)

	local screenElement = useMemo(function(): React.Node
		if currentScreen == "Home" then
			if activeStory and activeStorybook then
				return React.createElement(StoryCanvas, {
					story = activeStory,
					storybook = activeStorybook,
				})
			elseif unavailableStorybook then
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
		end
		return nil :: never
	end, { currentScreen } :: { unknown })

	return screenElement
end

return Screen
