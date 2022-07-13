local flipbook = script:FindFirstAncestor("flipbook")

local Roact = require(flipbook.Packages.Roact)

local PluginContext = Roact.createContext()

export type Props = {
	plugin: Plugin,
}

local function PluginProvider(props: Props)
	return Roact.createElement(PluginContext.Provider, {
		value = props.plugin,
	}, props[Roact.Children])
end

return {
	Context = PluginContext,
	Consumer = PluginContext.Consumer,
	Provider = PluginProvider,
}
