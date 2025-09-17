local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local ContextStack = require("@root/Common/ContextStack")
local LocalStorageContext = require("@root/Plugin/LocalStorageContext")
local NavigationContext = require("@root/Navigation/NavigationContext")
local PluginStore = require("@root/Plugin/PluginStore")
local TreeView = require("@root/TreeView")

local useEffect = React.useEffect

export type Props = {
	plugin: Plugin,
	overlayGui: GuiBase2d?,
	children: React.Node?,
}

local function ContextProviders(props: Props)
	useEffect(function()
		PluginStore.get(false).setPlugin(props.plugin)
	end, { props.plugin })

	return React.createElement(ContextStack, {
		providers = {
			React.createElement(Foundation.FoundationProvider, {
				-- TODO: Have this change based on the current Studio theme
				theme = Foundation.Enums.Theme.Dark,
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
