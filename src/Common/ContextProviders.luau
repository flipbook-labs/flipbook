local React = require("@pkg/React")

local ContextStack = require("@root/Common/ContextStack")
local ModalContext = require("@root/Modal/ModalContext")
local NavigationContext = require("@root/Navigation/NavigationContext")
local PluginContext = require("@root/Plugin/PluginContext")
local SettingsContext = require("@root/UserSettings/SettingsContext")

export type Props = {
	plugin: Plugin,
	children: React.Node?,
}

local function ContextProviders(props: Props)
	return React.createElement(ContextStack, {
		providers = {
			React.createElement(PluginContext.Provider, {
				plugin = props.plugin,
			}),
			React.createElement(NavigationContext.Provider, {
				defaultScreen = "Home",
			}),
			React.createElement(SettingsContext.Provider),
			React.createElement(ModalContext.Provider),
		},
	}, props.children)
end

return ContextProviders
