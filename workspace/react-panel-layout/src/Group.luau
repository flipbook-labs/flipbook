local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local Dragger = require("@root/Dragger")
local GroupContext = require("@root/GroupContext")
local Panel = require("@root/Panel")

export type GroupProps = {
	fillDirection: Enum.FillDirection?,
	size: UDim2?,
	LayoutOrder: number?,
	children: React.Node?,
}

local defaultProps = {
	fillDirection = Enum.FillDirection.Vertical,
}

local function isPanelElement(element)
	return typeof(element) == "table" and element.type == Panel
end

local function getPanelId(key, element): string
	if typeof(key) == "string" then
		return key
	end
	local id = element.props and element.props.id
	if typeof(id) == "string" then
		return id
	end
	error(`Panel at child index {tostring(key)} must have a string React key or a string 'id' prop`)
end

local function normalizeChildren(children)
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

	local sizes, setSizes = React.useState({} :: { [string]: number })

	local sizesRef = React.useRef({} :: { [string]: number })
	local sizesAtDragStart = React.useRef(nil :: { [string]: number }?)
	local constraintsRef = React.useRef({} :: { [string]: GroupContext.PanelConstraints })
	local absoluteSizeRef = React.useRef(Vector2.zero)
	local childIdsRef = React.useRef({} :: { string })

	sizesRef.current = sizes

	local registerPanel = React.useCallback(function(id, constraints)
		constraintsRef.current[id] = constraints
	end, {} :: { unknown })

	local unregisterPanel = React.useCallback(function(id)
		constraintsRef.current[id] = nil
	end, {} :: { unknown })

	local onDragStart = React.useCallback(function(_leftId, _rightId)
		local current = sizesRef.current
		local initialized = Sift.Dictionary.join({}, current)
		local anyNew = false
		local ids = childIdsRef.current
		local groupPixels = if isHorizontal then absoluteSizeRef.current.X else absoluteSizeRef.current.Y
		local defaultPixels = if #ids > 0 then groupPixels / #ids else 200
		for _, id in ipairs(ids) do
			if initialized[id] == nil then
				initialized[id] = defaultPixels
				anyNew = true
			end
		end
		if anyNew then
			sizesRef.current = initialized
			setSizes(initialized)
		end
		sizesAtDragStart.current = Sift.Dictionary.join({}, sizesRef.current)
	end, { isHorizontal } :: { unknown })

	local onDragContinue = React.useCallback(function(leftId, rightId, totalDelta: Vector2)
		local snapshot = sizesAtDragStart.current
		if not snapshot then
			return
		end

		local delta = if isHorizontal then totalDelta.X else totalDelta.Y

		local newLeft = (snapshot[leftId] or 200) + delta
		local newRight = (snapshot[rightId] or 200) - delta

		local function clampToConstraint(pixels, panelId)
			local c = constraintsRef.current[panelId]
			if not c then
				return math.max(0, pixels)
			end
			local mn = if isHorizontal then c.minSize.X else c.minSize.Y
			local mx = if isHorizontal then c.maxSize.X else c.maxSize.Y
			return math.clamp(pixels, mn, mx)
		end

		newLeft = clampToConstraint(newLeft, leftId)
		newRight = clampToConstraint(newRight, rightId)

		local newSizes = Sift.Dictionary.join(sizesRef.current, {
			[leftId] = newLeft,
			[rightId] = newRight,
		})
		sizesRef.current = newSizes
		setSizes(newSizes)
	end, { isHorizontal } :: { unknown })

	local onDragEnd = React.useCallback(function()
		sizesAtDragStart.current = nil
	end, {} :: { unknown })

	local childrenTable = normalizeChildren(props.children)

	local allChildren = {}
	for key, element in pairs(childrenTable) do
		table.insert(allChildren, {
			key = key,
			element = element,
			layoutOrder = (typeof(element) == "table" and element.props and element.props.LayoutOrder) or 0,
			isPanel = isPanelElement(element),
		})
	end

	table.sort(allChildren, function(a, b)
		if a.layoutOrder ~= b.layoutOrder then
			return a.layoutOrder < b.layoutOrder
		end
		return tostring(a.key) < tostring(b.key)
	end)

	local result: { [string]: any } = {}
	local newLayoutOrder = 0
	local childIds: { string } = {}

	for i, entry in ipairs(allChildren) do
		newLayoutOrder += 1

		local childId: string = if entry.isPanel then getPanelId(entry.key, entry.element) else tostring(entry.key)
		table.insert(childIds, childId)

		if entry.isPanel then
			result[entry.key] = React.cloneElement(entry.element, {
				id = childId,
				LayoutOrder = newLayoutOrder,
			})
		else
			local pixelSize = sizesRef.current[childId] or 200
			local childSize = if isHorizontal then UDim2.new(0, pixelSize, 1, 0) else UDim2.new(1, 0, 0, pixelSize)
			result[entry.key] = React.cloneElement(entry.element :: any, {
				LayoutOrder = newLayoutOrder,
				size = childSize,
			})
		end

		local nextEntry = allChildren[i + 1]
		if nextEntry then
			newLayoutOrder += 1
			local rightId: string = if nextEntry.isPanel
				then getPanelId(nextEntry.key, nextEntry.element)
				else tostring(nextEntry.key)
			local separatorKey = "Separator_" .. childId .. "_" .. rightId

			result[separatorKey] = React.createElement(Dragger, {
				LayoutOrder = newLayoutOrder,
				onDragStart = function()
					onDragStart(childId, rightId)
				end,
				onDrag = function(delta)
					onDragContinue(childId, rightId, delta)
				end,
				onDragEnd = onDragEnd,
			})
		end
	end

	childIdsRef.current = childIds

	return React.createElement(
		Foundation.View,
		{
			onAbsoluteSizeChanged = function(rbx: GuiObject)
				local newAbsoluteSize = rbx.AbsoluteSize
				absoluteSizeRef.current = newAbsoluteSize
				if next(sizesRef.current) == nil then
					local ids = childIdsRef.current
					if #ids > 0 then
						local groupPixels = if isHorizontal then newAbsoluteSize.X else newAbsoluteSize.Y
						local perChild = groupPixels / #ids
						local initialized = {}
						for _, id in ipairs(ids) do
							initialized[id] = perChild
						end
						sizesRef.current = initialized
						setSizes(initialized)
					end
				end
			end,
			tag = {
				["row"] = isHorizontal,
				["col"] = not isHorizontal,
				-- Only auto-fill when not explicitly sized by a parent Group.
				-- When a parent Group injects `size`, we use that instead.
				["fill auto-xy"] = props.size == nil,
				["gap-small"] = true,
			},
			layout = {
				FillDirection = fillDirection,
				ItemLineAlignment = Enum.ItemLineAlignment.Stretch,
			},
			Size = props.size,
			LayoutOrder = props.LayoutOrder,
		},
		React.createElement(GroupContext.Provider, {
			fillDirection = fillDirection,
			sizes = sizes,
			registerPanel = registerPanel,
			unregisterPanel = unregisterPanel,
		}, result)
	)
end

return React.memo(Group)
