local ModuleLoader = require("@pkg/ModuleLoader")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local AboutView = require("@root/About/AboutView")
local NavigationContext = require("@root/Navigation/NavigationContext")
local NoStorySelected = require("@root/Storybook/NoStorySelected")
local SettingsView = require("@root/UserSettings/SettingsView")
local StoryCanvas = require("@root/Storybook/StoryCanvas")

local useMemo = React.useMemo

type ModuleLoader = ModuleLoader.ModuleLoader
type LoadedStorybook = Storyteller.LoadedStorybook

export type Props = {
	loader: ModuleLoader,
	story: ModuleScript?,
	storybook: LoadedStorybook?,
}

local function Screen(props: Props)
	local navigation = NavigationContext.use()
	local currentScreen = navigation.currentScreen

	local screenElement = useMemo(function(): React.Node
		if currentScreen == "Home" then
			if props.story and props.storybook then
				return React.createElement(StoryCanvas, {
					loader = props.loader,
					story = props.story,
					storybook = props.storybook,
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
	end, { props, currentScreen } :: { unknown })

	return screenElement
end

return Screen
