local React = require("@pkg/React")

type PanelId = string
type SeparatorId = string

export type GroupContext = {
	fillDirection: Enum.FillDirection,
}

export type GroupProviderProps = {
	fillDirection: Enum.FillDirection,
	children: React.Node?,
}

local useMemo = React.useMemo

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
	return React.useContext(Context)
end

return {
	Provider = GroupProvider,
	use = use,
}
