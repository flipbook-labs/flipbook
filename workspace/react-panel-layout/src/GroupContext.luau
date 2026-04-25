local React = require("@pkg/React")

type PanelId = string

export type PanelConstraints = {
	minSize: Vector2,
	maxSize: Vector2,
}

export type GroupContext = {
	fillDirection: Enum.FillDirection,
	sizes: { [string]: number },
	registerPanel: (id: PanelId, constraints: PanelConstraints) -> (),
	unregisterPanel: (id: PanelId) -> (),
}

export type GroupProviderProps = {
	fillDirection: Enum.FillDirection,
	sizes: { [string]: number },
	registerPanel: (id: PanelId, constraints: PanelConstraints) -> (),
	unregisterPanel: (id: PanelId) -> (),
	children: React.Node?,
}

local defaultValue: GroupContext = {
	fillDirection = Enum.FillDirection.Vertical,
	sizes = {},
	registerPanel = function(_id, _constraints) end,
	unregisterPanel = function(_id) end,
}

local Context = React.createContext(defaultValue)

local function GroupProvider(props: GroupProviderProps)
	local context = React.useMemo(function()
		return {
			fillDirection = props.fillDirection,
			sizes = props.sizes,
			registerPanel = props.registerPanel,
			unregisterPanel = props.unregisterPanel,
		}
	end, {
		props.fillDirection,
		props.sizes,
		props.registerPanel,
		props.unregisterPanel,
	} :: { unknown })

	return React.createElement(Context.Provider, {
		value = context,
	}, props.children)
end

local function use(): GroupContext
	return React.useContext(Context)
end

return {
	Provider = GroupProvider,
	use = use,
}
