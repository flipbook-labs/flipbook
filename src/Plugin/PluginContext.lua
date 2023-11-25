local flipbook = script:FindFirstAncestor("flipbook")

local React = require(flipbook.Packages.React)

local PluginContext = React.createContext({})

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
