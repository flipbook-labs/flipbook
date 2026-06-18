local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local ContextStack = require("@root/Common/ContextStack")
local NavigationContext = require("@root/Navigation/NavigationContext")
local PluginStore = require("@root/Plugin/PluginStore")
local useThemeName = require("@root/Common/useThemeName")

local useEffect = React.useEffect

export type Props = {
	plugin: Plugin,
	theme: Foundation.Theme?,
	overlayGui: GuiBase2d?,
	children: React.Node?,
}

local function ContextProviders(props: Props)
	local themeName: Foundation.Theme = useThemeName()

	useEffect(function()
		PluginStore.get().setPlugin(props.plugin)
	end, { props.plugin })

	return React.createElement(ContextStack, {
		providers = {
			React.createElement(Foundation.FoundationProvider, {
				theme = props.theme or themeName,
				overlayGui = props.overlayGui,
			}),
			React.createElement(NavigationContext.Provider, {
				defaultScreen = "Home",
			}),
			React.createElement(Storyteller.StorytellerProvider),
		},
	}, props.children)
end

return ContextProviders
