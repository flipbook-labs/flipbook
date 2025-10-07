local Foundation = require(script.Parent.Parent.RobloxPackages.Foundation)
local React = require(script.Parent.Parent.Packages.React)

local ContextStack = require(script.Parent.ContextStack)
local NavigationContext = require(script.Parent.Parent.Navigation.NavigationContext)
local PluginStore = require(script.Parent.Parent.Plugin.PluginStore)
local TreeView = require(script.Parent.Parent.TreeView)
local useThemeName = require(script.Parent.useThemeName)

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
