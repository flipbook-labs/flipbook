local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local useCallback = React.useCallback
local useRef = React.useRef
local useState = React.useState

local Dragger = require("@root/Dragger")
local GroupContext = require("@root/GroupContext")
local Panel = require("@root/Panel")

export type GroupProps = {
	fillDirection: Enum.FillDirection?,
} & Panel.PanelProps

local defaultProps = {
	fillDirection = Enum.FillDirection.Vertical,
}

local DEFAULT_SIZE = 200

local function isPanelElement(element: any)
	return typeof(element) == "table" and element.type == Panel
end

local function getPanelId(key: string | number): string
	if typeof(key) == "string" then
		return key
	end
	error(`Panel at child index {tostring(key)} must have a string React key`)
end

local function normalizeChildren(children: any)
	if children == nil then
		return {}
	end
	-- Single React element has a 'type' field directly on it
	if typeof(children) == "table" and children.type ~= nil then
		return { children }
	end
	return children
end

local function Group(groupProps: GroupProps)
	local props = Sift.Dictionary.join(defaultProps, groupProps)
	local fillDirection: Enum.FillDirection = props.fillDirection
	local isHorizontal = fillDirection == Enum.FillDirection.Horizontal

	local sizes, setSizes = useState({} :: { [string]: number })

	local sizesRef = useRef({} :: { [string]: number })
	local sizesAtDragStart = useRef(nil :: { [string]: number }?)
	local constraintsRef = useRef({} :: { [string]: GroupContext.PanelConstraints })
	local defaultSizesRef = useRef({} :: { [string]: number })
	local flexPanelsRef = useRef({} :: { [string]: boolean })

	sizesRef.current = sizes

	local onDragStart = useCallback(function(leftId: string, rightId: string)
		sizesAtDragStart.current = {
			[leftId] = sizesRef.current[leftId] or defaultSizesRef.current[leftId] or DEFAULT_SIZE,
			[rightId] = sizesRef.current[rightId] or defaultSizesRef.current[rightId] or DEFAULT_SIZE,
		}
	end, {} :: { unknown })

	local onDragContinue = useCallback(function(leftId: string, rightId: string, totalDelta: Vector2)
		local snapshot = sizesAtDragStart.current
		if not snapshot then
			return
		end

		local delta = if isHorizontal then totalDelta.X else totalDelta.Y

		local function clampToConstraint(pixels: number, panelId: string)
			local c = constraintsRef.current[panelId]
			if not c then
				return math.max(0, pixels)
			end
			local mn = if isHorizontal then c.minSize.X else c.minSize.Y
			local mx = if isHorizontal then c.maxSize.X else c.maxSize.Y
			return math.clamp(pixels, mn, mx)
		end

		local newSizes = Sift.Dictionary.join(sizesRef.current, {})
		if not flexPanelsRef.current[leftId] then
			newSizes[leftId] = clampToConstraint((snapshot[leftId] or DEFAULT_SIZE) + delta, leftId)
		end
		if not flexPanelsRef.current[rightId] then
			newSizes[rightId] = clampToConstraint((snapshot[rightId] or DEFAULT_SIZE) - delta, rightId)
		end

		sizesRef.current = newSizes
		setSizes(newSizes)
	end, { isHorizontal } :: { unknown })

	local onDragEnd = useCallback(function()
		sizesAtDragStart.current = nil
	end, {} :: { unknown })

	local childrenTable = normalizeChildren(props.children)

	type ChildEntry = {
		key: string | number,
		element: any,
		layoutOrder: number,
		isPanel: boolean,
	}

	local allChildren: { ChildEntry } = {}
	for key, element in pairs(childrenTable) do
		table.insert(allChildren, {
			key = key,
			element = element,
			layoutOrder = (typeof(element) == "table" and element.props and element.props.LayoutOrder) or 0,
			isPanel = isPanelElement(element),
		})
	end

	table.sort(allChildren, function(a: ChildEntry, b: ChildEntry)
		if a.layoutOrder ~= b.layoutOrder then
			return a.layoutOrder < b.layoutOrder
		end
		return tostring(a.key) < tostring(b.key)
	end)

	local result: { [string | number]: any } = {}
	local newLayoutOrder = 0
	local newConstraints: { [string]: GroupContext.PanelConstraints } = {}
	local newDefaultSizes: { [string]: number } = {}
	local newFlexPanels: { [string]: boolean } = {}

	for i, entry in allChildren do
		newLayoutOrder += 1

		local childId: string = if entry.isPanel then getPanelId(entry.key) else tostring(entry.key)
		local childProps = entry.element.props
		local defaultSize: Vector2 = childProps.defaultSize or Vector2.new(DEFAULT_SIZE, DEFAULT_SIZE)

		newDefaultSizes[childId] = if isHorizontal then defaultSize.X else defaultSize.Y
		newFlexPanels[childId] = childProps.flexMode ~= nil

		if entry.isPanel then
			newConstraints[childId] = {
				minSize = childProps.minSize or Vector2.new(100, 100),
				maxSize = childProps.maxSize or Vector2.new(math.huge, math.huge),
			}
			result[entry.key] = React.cloneElement(entry.element, {
				id = childId,
				LayoutOrder = newLayoutOrder,
			})
		else
			local pixelSize = sizesRef.current[childId] or newDefaultSizes[childId]
			local childSize = if isHorizontal then UDim2.new(0, pixelSize, 1, 0) else UDim2.new(1, 0, 0, pixelSize)
			result[entry.key] = React.cloneElement(entry.element :: any, {
				LayoutOrder = newLayoutOrder,
				size = childSize,
			})
		end

		local nextEntry = allChildren[i + 1]
		if nextEntry then
			newLayoutOrder += 1
			local rightId: string = if nextEntry.isPanel then getPanelId(nextEntry.key) else tostring(nextEntry.key)
			local separatorKey = "Separator_" .. childId .. "_" .. rightId

			result[separatorKey] = React.createElement(Dragger, {
				LayoutOrder = newLayoutOrder,
				onDragStart = function()
					onDragStart(childId, rightId)
				end,
				onDrag = function(delta: Vector2)
					onDragContinue(childId, rightId, delta)
				end,
				onDragEnd = onDragEnd,
			})
		end
	end

	constraintsRef.current = newConstraints
	defaultSizesRef.current = newDefaultSizes
	flexPanelsRef.current = newFlexPanels

	return React.createElement(
		Foundation.View,
		{
			tag = {
				["row"] = isHorizontal,
				["col"] = not isHorizontal,
				-- Only auto-fill when not explicitly sized by a parent Group.
				-- When a parent Group injects `size`, we use that instead.
				["fill auto-xy"] = props.size == nil,
				["gap-small"] = true,
			},
			flexItem = {
				FlexMode = props.flexMode,
			},
			sizeConstraint = {
				MinSize = props.minSize,
				MaxSize = props.maxSize,
			},
			layout = {
				FillDirection = fillDirection,
			},
			Size = props.size,
			LayoutOrder = props.LayoutOrder,
		},
		React.createElement(GroupContext.Provider, {
			fillDirection = fillDirection,
			sizes = sizes,
		}, result)
	)
end

return React.memo(Group)
