--!nonstrict
-- Manages groups of selectable elements, reacting to selection changes for
-- individual items and triggering events for group selection changes
local Packages = script.Parent.Parent
local Cryo = require(Packages.Cryo)

local Input = require(script.Parent.Input)
local createSignal = require(script.Parent.createSignal)
local debugPrint = require(script.Parent.debugPrint)

local InternalApi = require(script.Parent.FocusControllerInternalApi)

local FocusControllerInternal = {}
FocusControllerInternal.__index = FocusControllerInternal

function FocusControllerInternal.new()
	local self = setmetatable({
		selectionChangedSignal = createSignal(),
		boundInputsChangedSignal = createSignal(),

		focusNodeTree = {},
		allNodes = {},

		rootRef = nil,
		engineInterface = nil,
		captureFocusOnInitialize = false,
		moveFocusToOnInitialize = nil,
		inputDisconnectors = {},
		boundInputs = {},
		focusedLeaf = nil,
		inProgressFocus = nil,
	}, FocusControllerInternal)

	return self
end

function FocusControllerInternal:isInitialized()
	return self.engineInterface ~= nil
end

function FocusControllerInternal:moveFocusTo(ref)
	if self.engineInterface == nil then
		self.moveFocusToOnInitialize = ref
		return
	end

	debugPrint("[FOCUS] Move focus to", ref)
	local node = self.allNodes[ref]

	if node ~= nil and not self:isNodeFocused(node) then
		node:focus()
	end
	self:debugPrintTree()
end

function FocusControllerInternal:moveFocusToNeighbor(neighborProp)
	if self.engineInterface == nil then
		error("FocusController is not connected to a component hierarchy!", 2)
	end

	if self.focusedLeaf ~= nil then
		debugPrint("[FOCUS] Move focus to", neighborProp, "from", self.focusedLeaf.ref)
		local refValue = self.focusedLeaf.ref:getValue()
		if refValue ~= nil and refValue[neighborProp] ~= nil then
			self:setSelection(refValue[neighborProp])
		end
	end
end

function FocusControllerInternal:getSelection()
	return self.engineInterface.getSelection()
end

function FocusControllerInternal:setSelection(ref)
	self.engineInterface.setSelection(ref)
end

function FocusControllerInternal:registerNode(parentNode, refKey, node)
	if parentNode ~= nil then
		debugPrint("[TREE ] Registering child node", refKey)

		local parentEntry = self.focusNodeTree[parentNode] or {}
		parentEntry[refKey] = node
		self.focusNodeTree[parentNode] = parentEntry
		self.allNodes[refKey] = node

		-- Different runtime scenarios can cause nodes to be registered after
		-- their respective host objects are already parented to the active
		-- focus tree; we should recalculate focus in both cases
		self:descendantAddedRefocus()
	else
		debugPrint("[TREE ] Registering root node", refKey)
		self.rootRef = refKey
		self.allNodes[refKey] = node

		if self.captureFocusOnRootRegistered then
			self.captureFocusOnRootRegistered = false
			self:captureFocus()
		end
	end
end

function FocusControllerInternal:deregisterNode(parentNode, refKey)
	if parentNode ~= nil then
		debugPrint("[TREE ] Deregistering child node", refKey)
		self.focusNodeTree[parentNode][refKey] = nil
		self.allNodes[refKey] = nil

		-- Different runtime scenarios can cause nodes to be deregistered after
		-- their respective host objects are already removed from the active
		-- focus tree; we should recalculate focus in both cases
		self:descendantRemovedRefocus()
	else
		debugPrint("[TREE ] Deregistering root node", refKey)
		self.allNodes[refKey] = nil
	end
end

function FocusControllerInternal:needsDescendantRemovedRefocus()
	-- If focusedLeaf is nil, then we've lost focus altogether, which likely
	-- means that focus belongs to a different focusable tree. Since that's out
	-- of our control, we can stop here.
	if self.focusedLeaf == nil then
		return
	end

	-- If the currently focused leaf has a nil ref, then its associated host
	-- component has unmounted and we need to refocus.
	return self.focusedLeaf.ref:getValue() == nil
end

function FocusControllerInternal:descendantRemovedRefocus()
	if self:needsDescendantRemovedRefocus() then
		debugPrint("[FOCUS] Focused node was removed; refocusing from nearest existing ancestor")

		-- Climb up the focusedLeaf's ancestry until we find a node that still
		-- exists; if we do find one, focus it
		local ancestorNode = self.focusedLeaf.parent
		while ancestorNode ~= nil and self.allNodes[ancestorNode.ref] == nil do
			ancestorNode = ancestorNode.parent
		end

		if ancestorNode ~= nil then
			ancestorNode:focus()
		end
	end
end

function FocusControllerInternal:needsDescendantAddedRefocus()
	-- If focusedLeaf is nil, then we've lost focus altogether, which likely
	-- means that focus belongs to a different focusable tree. Since that's out
	-- of our control, we can stop here.
	if self.focusedLeaf == nil then
		return nil
	end

	-- If the current focusedLeaf has children, then descendants must have been
	-- added to it, and we should re-run its focus logic.
	return not Cryo.isEmpty(self:getChildren(self.focusedLeaf))
end

function FocusControllerInternal:descendantAddedRefocus()
	if self:needsDescendantAddedRefocus() then
		-- A new descendant was introduced, which means that we need to refocus
		-- the current leaf
		debugPrint("[FOCUS] Currently-focused node is no longer a leaf; refocusing", self.focusedLeaf.ref)
		self.focusedLeaf:focus()
	end
end

function FocusControllerInternal:getChildren(parentNode)
	return self.focusNodeTree[parentNode] or {}
end

function FocusControllerInternal:isNodeFocused(node)
	if self.focusedLeaf == nil then
		return false
	end

	if self.focusedLeaf == node then
		return true
	end

	-- Find out if one of the focused leaf's parents is equal to the provided
	-- node, in which case, it remains in focus
	local parentNode = self.focusedLeaf.parent
	while parentNode ~= nil do
		if parentNode == node then
			return true
		end

		parentNode = parentNode.parent
	end

	return false
end

function FocusControllerInternal:setFocusedLeaf(node)
	self.focusedLeaf = node
end

function FocusControllerInternal:setInProgressFocus(node)
	self.inProgressFocus = node
end

function FocusControllerInternal:isInProgressFocus(node)
	return self.inProgressFocus == node
end

-- Prints a human-readable version of the node tree.
function FocusControllerInternal:debugPrintTree()
	if not debugPrint.isEnabled then
		return
	end

	local function recursePrintTree(node, indent)
		local nodeString = tostring(node.ref)
		if self:isNodeFocused(node) then
			nodeString ..= "*"
		end
		-- Print the current node
		debugPrint(indent, nodeString)

		-- Recurse through children
		local children = self:getChildren(node)
		for _, childNode in pairs(children) do
			recursePrintTree(childNode, indent .. "  ")
		end
	end

	debugPrint("Focus Node Tree:")
	local rootNode = self.allNodes[self.rootRef]
	recursePrintTree(rootNode, "  ")
end

function FocusControllerInternal:updateInputBindings()
	local newBindings = {}

	local focusChainNode = self.focusedLeaf
	while focusChainNode ~= nil do
		for _, binding in pairs(focusChainNode.inputBindings) do
			local key = Input.getUniqueKey(binding)
			local existing = newBindings[key]
			if existing == nil then
				debugPrint("[INPUT] Bind input", key)
				newBindings[key] = binding
			end
		end

		focusChainNode = focusChainNode.parent
	end

	-- It's pretty straightforward to simply disconnect and reconnect all event
	-- connections whenever this function is called; we wouldn't typically be
	-- able to rely on binding identity equality anyways
	for _, disconnector in pairs(self.inputDisconnectors) do
		disconnector()
	end

	self.inputDisconnectors = {}
	self.boundInputs = {}
	for key, binding in pairs(newBindings) do
		self.inputDisconnectors[key] = Input.connectToEvent(binding, self.engineInterface)
		if binding.keyCode then
			self.boundInputs[binding.keyCode] = binding.meta or {}
		end
	end
	self.boundInputsChangedSignal:fire(self.boundInputs)
end

function FocusControllerInternal:initialize(engineInterface)
	-- If the engineInterface is already set, then this FocusController was
	-- probably also assigned to another tree
	if self.engineInterface ~= nil then
		error(
			"FocusController cannot be initialized more than once; make sure you are not passing it to multiple components"
		)
	end

	self.engineInterface = engineInterface

	-- Create a connection to the GuiService property relevant to the navigation
	-- tree we want to connect
	self.guiServiceConnection = engineInterface.subscribeToSelectionChanged(function()
		-- This FocusController is not attached to an Instance hierarchy yet, so
		-- we shouldn't try to manage selection
		if self.rootRef == nil then
			return
		end

		-- Track whether or not the previous focus was inside this hierarchy
		local wasPreviouslyFocused = self.focusedLeaf ~= nil

		-- Nil out our focusedLeaf (we'll recalculate it if necessary) and get
		-- the current selection
		self.focusedLeaf = nil
		local selectedInstance = engineInterface.getSelection()
		local rootRefValue = self.rootRef:getValue()

		-- If selection is occurring within this FocusControllerInternal's
		-- hierarchy, we need to recompute the currently focused leaf
		if selectedInstance ~= nil then
			if rootRefValue == selectedInstance or selectedInstance:IsDescendantOf(rootRefValue) then
				debugPrint(
					"[EVENT] Selection changed to",
					selectedInstance,
					"in focus hierarchy beginning at",
					rootRefValue
				)

				-- Find the currently-focused node within our hierarchy and set
				-- self.focusedLeaf accordingly.
				for ref, node in pairs(self.allNodes) do
					if selectedInstance == ref:getValue() then
						self.focusedLeaf = node
						break
					end
				end
			end
		end

		-- We should fire our selectionChanged signal in the event that any of
		-- the following occur:
		-- 1. Selection moved within the hierarchy
		-- 2. Selection moved from outside the hierarchy to an element inside it
		-- 3. Selection moved from inside the hierarchy to an element outside it
		if self.focusedLeaf ~= nil or wasPreviouslyFocused then
			self.selectionChangedSignal:fire()

			-- Update input connections here
			self:updateInputBindings()
		end
	end)

	if self.captureFocusOnInitialize then
		self:captureFocus()
	end

	if self.moveFocusToOnInitialize then
		self:moveFocusTo(self.moveFocusToOnInitialize)
	end
end

function FocusControllerInternal:captureFocus()
	if self.engineInterface == nil then
		self.captureFocusOnInitialize = true
	elseif self.rootRef == nil then
		self.captureFocusOnRootRegistered = true
	else
		self.allNodes[self.rootRef]:focus()
		self:debugPrintTree()
	end
end

function FocusControllerInternal:releaseFocus()
	if self.engineInterface ~= nil then
		self.engineInterface.setSelection(nil)
	end
	self.captureFocusOnInitialize = false
	self.captureFocusOnRootRegistered = false
end

function FocusControllerInternal:teardown()
	if self.guiServiceConnection ~= nil then
		self.guiServiceConnection:Disconnect()
	end

	-- Disconnect all bound inputs. These can be left dangling when a whole tree
	-- is unmounted at once
	for _, disconnect in pairs(self.inputDisconnectors) do
		disconnect()
	end

	-- Make sure this controller is restored to its uninitialized state
	self.rootRef = nil
	self.engineInterface = nil
	self.captureFocusOnInitialize = false
	self.captureFocusOnRootRegistered = false
	self.focusedLeaf = nil
end

function FocusControllerInternal:subscribeToSelectionChange(callback)
	debugPrint("[TREE ] New subscription to selection change event")
	return self.selectionChangedSignal:subscribe(callback)
end

-- Creates an object with a public API for managing focus. This object can be
-- used in components to direct focus as necessary
function FocusControllerInternal.createPublicApiWrapper()
	local focusControllerInternal = FocusControllerInternal.new()

	return {
		[InternalApi] = focusControllerInternal,
		moveFocusTo = function(...)
			focusControllerInternal:moveFocusTo(...)
		end,
		moveFocusLeft = function()
			focusControllerInternal:moveFocusToNeighbor("NextSelectionLeft")
		end,
		moveFocusRight = function()
			focusControllerInternal:moveFocusToNeighbor("NextSelectionRight")
		end,
		moveFocusUp = function()
			focusControllerInternal:moveFocusToNeighbor("NextSelectionUp")
		end,
		moveFocusDown = function()
			focusControllerInternal:moveFocusToNeighbor("NextSelectionDown")
		end,
		captureFocus = function()
			focusControllerInternal:captureFocus()
		end,
		releaseFocus = function()
			focusControllerInternal:releaseFocus()
		end,
		getCurrentFocus = function()
			local focusedLeaf = focusControllerInternal.focusedLeaf
			return focusedLeaf and focusedLeaf.ref or nil
		end,
		getBoundInputs = function()
			return focusControllerInternal.boundInputs
		end,
		subscribeToBoundInputsChanged = function(callback)
			return focusControllerInternal.boundInputsChangedSignal:subscribe(callback)
		end,
	}
end

return FocusControllerInternal
