local React = require(script.Parent.Parent.Packages.React)
local Storyteller = require(script.Parent.Parent.Packages.Storyteller)

local AboutView = require(script.Parent.Parent.About.AboutView)
local NavigationContext = require(script.Parent.NavigationContext)
local NoStorySelected = require(script.Parent.Parent.Storybook.NoStorySelected)
local SettingsView = require(script.Parent.Parent.UserSettings.SettingsView)
local StoryCanvas = require(script.Parent.Parent.Storybook.StoryCanvas)
local StorybookError = require(script.Parent.Parent.Storybook.StorybookError)

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
				return React.createElement(StoryCanvas, {
					story = props.story,
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
		end
		return nil :: never
	end, { props, currentScreen } :: { unknown })

	return screenElement
end

return Screen
