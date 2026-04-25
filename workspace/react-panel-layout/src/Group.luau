local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local Dragger = require("@root/Dragger")
local GroupContext = require("@root/GroupContext")
local Panel = require("@root/Panel")

export type GroupProps = {
	fillDirection: Enum.FillDirection?,
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

	local weights, setWeights = React.useState({} :: { [string]: number })

	-- Refs so stable useCallback closures always see the latest values
	local weightsRef = React.useRef({} :: { [string]: number })
	local weightsAtDragStart = React.useRef(nil :: { [string]: number }?)
	local constraintsRef = React.useRef({} :: { [string]: GroupContext.PanelConstraints })
	local absoluteSizeRef = React.useRef(Vector2.zero)
	-- All direct child IDs in sorted render order; used to initialize weights for
	-- every child (including non-Panel children like nested Groups) on first drag.
	local childIdsRef = React.useRef({} :: { string })

	-- Mirror state into ref so drag callbacks never capture stale weights
	weightsRef.current = weights

	local registerPanel = React.useCallback(function(id, constraints)
		-- Store constraints only — weight is initialized lazily in onDragStart so
		-- this callback never calls setWeights from within a child's render pass.
		constraintsRef.current[id] = constraints
	end, {} :: { unknown })

	local unregisterPanel = React.useCallback(function(id)
		constraintsRef.current[id] = nil
	end, {} :: { unknown })

	local getWeight = React.useCallback(function(id)
		-- Fall back to 1 before the first drag so all panels start at equal weight.
		return weightsRef.current[id] or 1
	end, {} :: { unknown })

	local onDragStart = React.useCallback(function(_leftId, _rightId)
		-- Ensure every direct child has an explicit weight entry before we snapshot.
		-- This covers both Panel children (registered via constraintsRef) and
		-- non-Panel children like nested Groups (tracked only in childIdsRef).
		local current = weightsRef.current
		local initialized = Sift.Dictionary.join({}, current)
		local anyNew = false
		for _, id in ipairs(childIdsRef.current) do
			if initialized[id] == nil then
				initialized[id] = 1
				anyNew = true
			end
		end
		if anyNew then
			weightsRef.current = initialized
			setWeights(initialized)
		end
		weightsAtDragStart.current = Sift.Dictionary.join({}, weightsRef.current)
	end, {} :: { unknown })

	local onDragContinue = React.useCallback(function(leftId, rightId, totalDelta: Vector2)
		local snapshot = weightsAtDragStart.current
		if not snapshot then
			return
		end

		local groupPixels = if isHorizontal then absoluteSizeRef.current.X else absoluteSizeRef.current.Y
		if groupPixels <= 0 then
			return
		end

		local totalWeight = 0
		for _, w in pairs(snapshot) do
			totalWeight += w
		end
		if totalWeight <= 0 then
			return
		end

		local pixelLeft = (snapshot[leftId] or 0) / totalWeight * groupPixels
		local pixelRight = (snapshot[rightId] or 0) / totalWeight * groupPixels

		local delta = if isHorizontal then totalDelta.X else totalDelta.Y
		local newPixelLeft = pixelLeft + delta
		local newPixelRight = pixelRight - delta

		local function clampToConstraint(pixels, panelId)
			local c = constraintsRef.current[panelId]
			if not c then
				return pixels
			end
			local mn = if isHorizontal then c.minSize.X else c.minSize.Y
			local mx = if isHorizontal then c.maxSize.X else c.maxSize.Y
			return math.clamp(pixels, mn, math.min(mx, groupPixels))
		end

		newPixelLeft = clampToConstraint(newPixelLeft, leftId)
		newPixelRight = clampToConstraint(newPixelRight, rightId)

		local newWeightLeft = newPixelLeft / groupPixels * totalWeight
		local newWeightRight = newPixelRight / groupPixels * totalWeight

		local newWeights = Sift.Dictionary.join(weightsRef.current, {
			[leftId] = newWeightLeft,
			[rightId] = newWeightRight,
		})
		weightsRef.current = newWeights
		setWeights(newWeights)
	end, { isHorizontal } :: { unknown })

	local onDragEnd = React.useCallback(function()
		weightsAtDragStart.current = nil
	end, {} :: { unknown })

	-- Build the children table: sort all children by LayoutOrder, inject a Dragger
	-- between every consecutive Panel pair, and assign fresh sequential LayoutOrders
	-- so the injected Draggers always slot correctly between their neighbors.
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

		local weight = weightsRef.current[childId] or 1

		if entry.isPanel then
			-- Panel reads its own weight via GroupContext.getWeight and applies flexItem
			-- itself; Group only needs to inject the stable id and updated LayoutOrder.
			result[entry.key] = React.cloneElement(entry.element, {
				id = childId,
				LayoutOrder = newLayoutOrder,
			})
		else
			-- Non-Panel children (e.g. nested Groups) don't self-register, so Group
			-- injects flexItem directly so they participate in flex resizing.
			result[entry.key] = React.cloneElement(entry.element :: any, {
				LayoutOrder = newLayoutOrder,
				flexItem = {
					FlexMode = Enum.UIFlexMode.Custom,
					GrowRatio = weight,
				},
			})
		end

		-- Insert a Dragger between every consecutive child pair, regardless of type.
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
			onAbsoluteSizeChanged = function(rbx)
				absoluteSizeRef.current = rbx.AbsoluteSize
			end,
			tag = {
				["row"] = isHorizontal,
				["col"] = not isHorizontal,
				["auto-xy fill gap-small"] = true,
			},
			layout = {
				FillDirection = fillDirection,
				ItemLineAlignment = Enum.ItemLineAlignment.Stretch,
			},
			LayoutOrder = props.LayoutOrder,
		},
		React.createElement(GroupContext.Provider, {
			fillDirection = fillDirection,
			weights = weights,
			getWeight = getWeight,
			registerPanel = registerPanel,
			unregisterPanel = unregisterPanel,
			onDragStart = onDragStart,
			onDragContinue = onDragContinue,
			onDragEnd = onDragEnd,
		}, result)
	)
end

return React.memo(Group)
