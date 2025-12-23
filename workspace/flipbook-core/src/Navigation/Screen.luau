local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local AboutView = require("@root/About/AboutView")
local LogsView = require("@root/Logs/LogsView")
local NavigationContext = require("@root/Navigation/NavigationContext")
local NoStorySelected = require("@root/Storybook/NoStorySelected")
local SettingsView = require("@root/UserSettings/SettingsView")
local StoryView = require("@root/Storybook/StoryView")
local StorybookError = require("@root/Storybook/StorybookError")

local useMemo = React.useMemo

type LoadedStorybook = Storyteller.LoadedStorybook
type UnavailableStorybook = Storyteller.UnavailableStorybook

export type Props = {
	story: ModuleScript?,
	storybook: LoadedStorybook?,
	unavailableStorybook: UnavailableStorybook?,
}

local function Screen(props: Props)
	local navigation = NavigationContext.use()
	local currentScreen = navigation.currentScreen

	local screenElement = useMemo(function(): React.Node
		if currentScreen == "Home" then
			if props.story and props.storybook then
				return React.createElement(StoryView, {
					storyModule = props.story,
					storybook = props.storybook,
				})
			elseif props.unavailableStorybook then
				return React.createElement(StorybookError, {
					unavailableStorybook = props.unavailableStorybook,
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
	end, { props, currentScreen } :: { unknown })

	return screenElement
end

return Screen
