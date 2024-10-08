local ModuleLoader = require("@pkg/ModuleLoader")
local React = require("@pkg/React")

local NavigationContext = require("@root/Navigation/NavigationContext")
local SettingsView = require("@root/UserSettings/SettingsView")
local StoryCanvas = require("@root/Storybook/StoryCanvas")
local storybookTypes = require("@root/Storybook/types")

local useMemo = React.useMemo

type Story = storybookTypes.Story
type Storybook = storybookTypes.Storybook

export type Props = {
	loader: ModuleLoader.ModuleLoader,
	story: ModuleScript?,
	storybook: Storybook?,
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
			end
		elseif currentScreen == "Settings" then
			return React.createElement(SettingsView)
		end
		return nil
	end, { props, currentScreen } :: { unknown })

	return screenElement
end

return Screen
