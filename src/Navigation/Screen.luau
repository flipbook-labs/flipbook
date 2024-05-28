local React = require("@pkg/React")

local AboutView = require("@root/About/AboutView")
local NavigationContext = require("@root/Navigation/NavigationContext")
local SettingsView = require("@root/UserSettings/SettingsView")
local StoryCanvas = require("@root/Storybook/StoryCanvas")
local storybookTypes = require("@root/Storybook/types")

local useMemo = React.useMemo

type Story = storybookTypes.Story
type Storybook = storybookTypes.Storybook

export type Props = {
	loader: any,
	story: Story?,
	storybook: Storybook?,
}

local function Screen(props: Props)
	local navigation = NavigationContext.use()
	local currentScreen = navigation.currentScreen

	local screenElement = useMemo(function()
		if currentScreen == "Home" then
			return React.createElement(StoryCanvas, {
				loader = props.loader,
				story = props.story,
				storybook = props.storybook,
			})
		elseif currentScreen == "Settings" then
			return React.createElement(SettingsView)
		elseif currentScreen == "About" then
			return React.createElement(AboutView)
		else
			return nil
		end
	end, { props, currentScreen })

	return screenElement
end

return Screen
