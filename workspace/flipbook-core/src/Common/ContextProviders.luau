local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local AgentContext = require("@root/Agent/AgentContext")
local AgentTypes = require("@root/Agent/types")
local CommonTypes = require("@root/Common/types")
local ContextStack = require("@root/Common/ContextStack")
local NavigationContext = require("@root/Navigation/NavigationContext")
local PluginStore = require("@root/Plugin/PluginStore")
local useThemeName = require("@root/Common/useThemeName")

local useEffect = React.useEffect

type Pluginlike = CommonTypes.Pluginlike
type AgentController = AgentTypes.AgentController

export type Props = {
	plugin: Pluginlike,
	theme: Foundation.Theme?,
	overlayGui: GuiBase2d?,
	agentController: AgentController?,
	children: React.Node?,
}

local function ContextProviders(props: Props)
	local themeName: Foundation.Theme = useThemeName()

	useEffect(function()
		PluginStore.get().setPlugin(props.plugin)
	end, { props.plugin })

	return React.createElement(ContextStack, {
		providers = {
			React.createElement(AgentContext.Provider, {
				value = props.agentController,
			}),
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
