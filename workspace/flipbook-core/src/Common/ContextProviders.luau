local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Storyteller = require("@pkg/Storyteller")

local CommonTypes = require("@root/Common/types")
local ContextStack = require("@root/Common/ContextStack")
local NavigationContext = require("@root/Navigation/NavigationContext")
local PluginStore = require("@root/Plugin/PluginStore")
local useColorMode = require("@root/Common/useColorMode")
local useThemeName = require("@root/Common/useThemeName")

local useEffect = React.useEffect

type Pluginlike = CommonTypes.Pluginlike

export type Props = {
	plugin: Pluginlike,
	colorMode: Foundation.ColorMode?,
	themeName: Foundation.ThemeName?,
	overlayGui: GuiBase2d?,
	children: React.Node?,
}

local function ContextProviders(props: Props)
	local colorMode: Foundation.ColorMode = useColorMode()
	local themeName: Foundation.ThemeName = useThemeName()

	useEffect(function()
		PluginStore.get().setPlugin(props.plugin)
	end, { props.plugin })

	return React.createElement(ContextStack, {
		providers = {
			React.createElement(Foundation.FoundationProvider, {
				colorMode = props.colorMode or colorMode,
				themeName = props.themeName or themeName,
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
