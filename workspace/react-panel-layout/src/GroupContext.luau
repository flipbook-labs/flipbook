local React = require("@pkg/React")

type PanelId = string

export type PanelConstraints = {
	minSize: Vector2,
	maxSize: Vector2,
}

export type GroupContext = {
	fillDirection: Enum.FillDirection,
	weights: { [string]: number },
	getWeight: (id: PanelId) -> number,
	registerPanel: (id: PanelId, constraints: PanelConstraints) -> (),
	unregisterPanel: (id: PanelId) -> (),
	onDragStart: (leftId: PanelId, rightId: PanelId) -> (),
	onDragContinue: (leftId: PanelId, rightId: PanelId, totalDelta: Vector2) -> (),
	onDragEnd: () -> (),
}

export type GroupProviderProps = {
	fillDirection: Enum.FillDirection,
	weights: { [string]: number },
	getWeight: (id: PanelId) -> number,
	registerPanel: (id: PanelId, constraints: PanelConstraints) -> (),
	unregisterPanel: (id: PanelId) -> (),
	onDragStart: (leftId: PanelId, rightId: PanelId) -> (),
	onDragContinue: (leftId: PanelId, rightId: PanelId, totalDelta: Vector2) -> (),
	onDragEnd: () -> (),
	children: React.Node?,
}

local defaultValue: GroupContext = {
	fillDirection = Enum.FillDirection.Vertical,
	weights = {},
	getWeight = function(_id) return 1 end,
	registerPanel = function(_id, _constraints) end,
	unregisterPanel = function(_id) end,
	onDragStart = function(_l, _r) end,
	onDragContinue = function(_l, _r, _d) end,
	onDragEnd = function() end,
}

local Context = React.createContext(defaultValue)

local function GroupProvider(props: GroupProviderProps)
	-- Stable object identity: rebuild only when the callbacks or fillDirection change.
	-- Callbacks are stable useCallback refs owned by Group, so this memo rarely fires.
	local context = React.useMemo(function()
		return {
			fillDirection = props.fillDirection,
			weights = props.weights,
			getWeight = props.getWeight,
			registerPanel = props.registerPanel,
			unregisterPanel = props.unregisterPanel,
			onDragStart = props.onDragStart,
			onDragContinue = props.onDragContinue,
			onDragEnd = props.onDragEnd,
		}
	end, {
		props.fillDirection,
		props.weights,
		props.getWeight,
		props.registerPanel,
		props.unregisterPanel,
		props.onDragStart,
		props.onDragContinue,
		props.onDragEnd,
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
