local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local ContextStack = require("@root/Common/ContextStack")
local NavigationContext = require("@root/Navigation/NavigationContext")
local PluginStore = require("@root/Plugin/PluginStore")
local TreeView = require("@root/TreeView")
local useThemeName = require("@root/Common/useThemeName")

local useEffect = React.useEffect

export type Props = {
	plugin: Plugin,
	overlayGui: GuiBase2d?,
	children: React.Node?,
}

local function ContextProviders(props: Props)
	local themeName: "Dark" | "Light" = useThemeName()

	useEffect(function()
		PluginStore.get(false).setPlugin(props.plugin)
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
			React.createElement(TreeView.TreeViewProvider),
		},
	}, props.children)
end

return ContextProviders
