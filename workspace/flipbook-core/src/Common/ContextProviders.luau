local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local Actions = require("@root/Actions")
local ActionsContext = require("@root/Actions/ActionsContext")
local ContextStack = require("@root/Common/ContextStack")
local NavigationContext = require("@root/Navigation/NavigationContext")
local PluginStore = require("@root/Plugin/PluginStore")
local useThemeName = require("@root/Common/useThemeName")

local useEffect = React.useEffect

export type Props = {
	plugin: Plugin,
	overlayGui: GuiBase2d?,
	controller: Actions.AppController?,
	children: React.Node?,
}

local function ContextProviders(props: Props)
	local themeName: "Dark" | "Light" = useThemeName()

	useEffect(function()
		PluginStore.get().setPlugin(props.plugin)
	end, { props.plugin })

	return React.createElement(ContextStack, {
		providers = {
			React.createElement(Foundation.FoundationProvider, {
				theme = themeName,
				overlayGui = props.overlayGui,
			}),
			React.createElement(NavigationContext.Provider, {
				defaultScreen = "Home",
			}),
			React.createElement(ActionsContext.Provider, {
				value = props.controller,
			}),
			React.createElement(Storyteller.StorytellerProvider),
		},
	}, props.children)
end

return ContextProviders
