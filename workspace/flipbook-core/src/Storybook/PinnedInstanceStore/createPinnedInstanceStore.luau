local Sift = require("@pkg/Sift")
local Signals = require("@rbxpkg/Signals")
local Telemetry = require("@workspace/telemetry/src")

local LocalStorageStore = require("@root/Plugin/LocalStorageStore")
local getInstanceFromPath = require("@root/Common/getInstanceFromPath")
local getInstancePath = require("@root/Common/getInstancePath")

export type PinnedInstance = {
	path: string,
	instance: Instance?,
}

export type PinnedInstanceStore = {
	getPinnedInstances: Signals.getter<{ PinnedInstance }>,
	isPinned: (instance: Instance) -> boolean,
	pin: (instance: Instance) -> (),
	unpin: (instance: Instance) -> (),
}

local function createPinnedInstanceStore(parentScope: Signals.scope): PinnedInstanceStore
	local localStorageStore = LocalStorageStore.get(parentScope)

	local getPinnedPaths = Signals.createComputed(function(scope)
		local storage = localStorageStore.getStorage(scope)
		return storage.pinnedInstancePaths or {}
	end)

	local function setPinnedPaths(update: (prev: { string }) -> { string })
		localStorageStore.setStorage(function(prev)
			return Sift.Dictionary.join(prev, {
				pinnedInstancePaths = update(prev.pinnedInstancePaths or {}),
			})
		end)
	end

	local getPinnedInstances = Signals.createComputed(function(scope)
		local pinnedPaths = getPinnedPaths(scope)

		return Sift.List.map(pinnedPaths, function(pinnedPath)
			return {
				path = pinnedPath,
				instance = getInstanceFromPath(pinnedPath),
			} :: PinnedInstance
		end)
	end)

	local function pin(instance: Instance)
		Telemetry.fireEvent({
			eventName = "NodePinned",
		})
		setPinnedPaths(function(prev)
			return Sift.List.append(prev, getInstancePath(instance))
		end)
	end

	local function unpin(instance: Instance)
		Telemetry.fireEvent({
			eventName = "NodeUnpinned",
		})
		setPinnedPaths(function(prev)
			return Sift.List.removeValue(prev, getInstancePath(instance))
		end)
	end

	local function isPinned(instance: Instance)
		return Sift.List.has(getPinnedPaths(false), getInstancePath(instance))
	end

	return {
		pin = pin,
		unpin = unpin,
		isPinned = isPinned,
		getPinnedInstances = getPinnedInstances,
	}
end

return createPinnedInstanceStore
