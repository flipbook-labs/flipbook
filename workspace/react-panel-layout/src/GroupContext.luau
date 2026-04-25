local React = require("@pkg/React")

local useContext = React.useContext
local useMemo = React.useMemo

export type PanelConstraints = {
	minSize: Vector2,
	maxSize: Vector2,
}

export type GroupContext = {
	fillDirection: Enum.FillDirection,
}

export type GroupProviderProps = {
	fillDirection: Enum.FillDirection,
	children: React.Node?,
}

local defaultValue: GroupContext = {
	fillDirection = Enum.FillDirection.Vertical,
}

local Context = React.createContext(defaultValue)

local function GroupProvider(props: GroupProviderProps)
	local context = useMemo(function()
		return {
			fillDirection = props.fillDirection,
		}
	end, { props.fillDirection } :: { unknown })

	return React.createElement(Context.Provider, {
		value = context,
	}, props.children)
end

local function use(): GroupContext
	return useContext(Context)
end

return {
	Provider = GroupProvider,
	use = use,
}
