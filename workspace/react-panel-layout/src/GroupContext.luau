local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local useCallback = React.useCallback
local useContext = React.useContext
local useMemo = React.useMemo
local useRef = React.useRef
local useState = React.useState

type PanelConstraints = {
	defaultSize: number,
	minSize: number,
	maxSize: number,
	flexMode: Enum.UIFlexMode,
}

export type GroupContext = {
	fillDirection: Enum.FillDirection,
	sizes: { [string]: number },
	setSizes: (sizes: { [string]: number }) -> (),
	setPanelSize: (panelId: string, size: number) -> (),
	getPanelSize: (panelId: string) -> React.Binding<number>,
	registerPanel: (panelId: string, constraints: PanelConstraints) -> (),
	unregisterPanel: (panelId: string) -> (),
}

local Context = React.createContext({
	fillDirection = Enum.FillDirection.Vertical,
	sizes = {},
	setSizes = function() end,
	setPanelSize = function() end,
	getPanelSize = function()
		return React.createBinding(0)
	end,
	registerPanel = function() end,
	unregisterPanel = function() end,
} :: GroupContext)

export type GroupProviderProps = {
	fillDirection: Enum.FillDirection?,
	children: React.Node?,
}

local defaultProps = {
	fillDirection = Enum.FillDirection.Vertical,
}

type StoredBinding = {
	binding: React.Binding<number>,
	update: (number) -> (),
}

local function GroupProvider(groupProviderProps: GroupProviderProps)
	local props = Sift.Dictionary.join(defaultProps, groupProviderProps)

	print("group", props.fillDirection)

	local panels = useRef({} :: { [string]: PanelConstraints })
	local sizeBindings = useRef({} :: { [string]: StoredBinding })

	local createSizeBinding = useCallback(function(panelId: string, defaultSize: number): React.Binding<number>
		local newBinding, setNewBinding = React.createBinding(defaultSize)

		sizeBindings.current[panelId] = {
			binding = newBinding,
			update = setNewBinding,
		}

		return newBinding
	end, {})

	local setPanelSize = useCallback(function(panelId: string, size: number)
		local sizeBinding = sizeBindings.current[panelId]
		if sizeBinding then
			sizeBinding.update(size)
		else
			createSizeBinding(panelId, size)
		end
	end, {})

	local registerPanel = useCallback(function(panelId: string, constraints: PanelConstraints)
		panels.current[panelId] = constraints
		setPanelSize(panelId, constraints.defaultSize)
	end, {})

	local unregisterPanel = useCallback(function(panelId: string)
		panels.current[panelId] = nil
		sizeBindings.current[panelId] = nil
	end, {})

	-- Always returns a consistent Binding, even if it hasn't been setup yet. A
	-- Panel stills needs to call `registerPanel` to fill in default sizes and
	-- constraints
	local getPanelSize = useCallback(function(panelId: string): React.Binding<number>
		local existing = sizeBindings.current[panelId]
		if existing then
			return existing.binding
		else
			return createSizeBinding(panelId, 0)
		end
	end, {})

	local context = useMemo(
		function()
			return {
				fillDirection = props.fillDirection,
				sizes = sizeBindings,

				registerPanel = registerPanel,
				unregisterPanel = unregisterPanel,

				getPanelSize = getPanelSize,
			}
		end,
		{
			props.fillDirection,
			sizeBindings,
			getPanelSize,
			registerPanel,
			unregisterPanel,
		} :: { unknown }
	)

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
