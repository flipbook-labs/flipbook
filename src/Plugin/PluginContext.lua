local React = require("@pkg/React")

local PluginContext = React.createContext(nil :: Plugin?)

export type Props = {
	plugin: Plugin,
	children: any,
}

local function PluginProvider(props: Props)
	return React.createElement(PluginContext.Provider, {
		value = props.plugin,
	}, props.children)
end

return {
	Context = PluginContext,
	Consumer = PluginContext.Consumer,
	Provider = PluginProvider,
}
