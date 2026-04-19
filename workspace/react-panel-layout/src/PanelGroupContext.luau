local React = require("@pkg/React")

local types = require("@root/types")

type PanelGroupContext = types.PanelGroupContext
type LayoutSizes = types.LayoutSizes
type GroupProps = types.GroupProps

local useCallback = React.useCallback
local useEffect = React.useEffect
local useMemo = React.useMemo
local useRef = React.useRef
local useState = React.useState

local Context = React.createContext({
	sizes = {},
	orientation = "horizontal" :: "horizontal",
	groupAbsoluteSize = Vector2.zero,
	separatorsTotalSize = 0,
	updateSizes = function(_newSizes: LayoutSizes) end,
	registerPanel = function(_id: string, _defaultSize: number, _constraints: NumberRange?) end,
	unregisterPanel = function(_id: string) end,
	panelConstraints = {},
	registerSeparator = function(_separatorSize: number) end,
	unregisterSeparator = function(_separatorSize: number) end,
} :: PanelGroupContext)

--[[
	Provider manages all layout state and renders the root Frame + UIListLayout.
	Group uses Provider as its root element.
]]
local function Provider(props: GroupProps)
	local sizes, setSizes = useState((props.defaultLayout or {}) :: LayoutSizes)
	local panelConstraints, setPanelConstraints = useState({} :: { [string]: NumberRange })
	local separatorsTotalSize, setSeparatorsTotalSize = useState(0)
	local groupAbsoluteSize, setGroupAbsoluteSize = useState(Vector2.zero)

	local frameRef = useRef(nil :: Frame?)

	useEffect(function(): (() -> ())?
		local frame = frameRef.current
		if not frame then
			return nil
		end

		setGroupAbsoluteSize(frame.AbsoluteSize)

		local conn = frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			setGroupAbsoluteSize(frame.AbsoluteSize)
		end)

		return function()
			conn:Disconnect()
		end
	end, { frameRef.current } :: { unknown })

	local registerPanel = useCallback(function(id: string, defaultSize: number, constraints: NumberRange?)
		setSizes(function(prev)
			if prev[id] ~= nil then
				return prev
			end
			local initialSize = if props.defaultLayout and props.defaultLayout[id] ~= nil
				then props.defaultLayout[id]
				else defaultSize
			local next = table.clone(prev)
			next[id] = initialSize
			return next
		end)

		if constraints then
			setPanelConstraints(function(prev)
				if prev[id] then
					return prev
				end
				local next = table.clone(prev)
				next[id] = constraints
				return next
			end)
		end
	end, { props.defaultLayout } :: { unknown })

	local unregisterPanel = useCallback(function(id: string)
		setSizes(function(prev)
			local next = table.clone(prev)
			next[id] = nil
			return next
		end)
		setPanelConstraints(function(prev)
			local next = table.clone(prev)
			next[id] = nil
			return next
		end)
	end, {})

	local updateSizes = useCallback(function(newSizes: LayoutSizes)
		setSizes(newSizes)
		if props.onLayoutChange then
			props.onLayoutChange(props.id, newSizes)
		end
	end, { props.onLayoutChange, props.id } :: { unknown })

	local registerSeparator = useCallback(function(separatorSize: number)
		setSeparatorsTotalSize(function(prev)
			return prev + separatorSize
		end)
	end, {})

	local unregisterSeparator = useCallback(function(separatorSize: number)
		setSeparatorsTotalSize(function(prev)
			return math.max(0, prev - separatorSize)
		end)
	end, {})

	local contextValue = useMemo(
		function()
			return {
				sizes = sizes,
				orientation = props.orientation,
				groupAbsoluteSize = groupAbsoluteSize,
				separatorsTotalSize = separatorsTotalSize,
				updateSizes = updateSizes,
				registerPanel = registerPanel,
				unregisterPanel = unregisterPanel,
				panelConstraints = panelConstraints,
				registerSeparator = registerSeparator,
				unregisterSeparator = unregisterSeparator,
			}
		end,
		{
			sizes,
			props.orientation,
			groupAbsoluteSize,
			separatorsTotalSize,
			updateSizes,
			registerPanel,
			unregisterPanel,
			panelConstraints,
			registerSeparator,
			unregisterSeparator,
		} :: { unknown }
	)

	local fillDirection = if props.orientation == "horizontal"
		then Enum.FillDirection.Horizontal
		else Enum.FillDirection.Vertical

	return React.createElement(Context.Provider, {
		value = contextValue,
	}, {
		Frame = React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ref = frameRef,
		}, {
			Layout = React.createElement("UIListLayout", {
				FillDirection = fillDirection,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 0),
			}),

			Children = React.createElement(React.Fragment, nil, props.children),
		}),
	})
end

local function use(): PanelGroupContext
	return React.useContext(Context)
end

return {
	Provider = Provider,
	use = use,
}
