local Charm = require("@pkg/Charm")
local Sift = require("@pkg/Sift")

local LocalStorageStore = require("@root/Plugin/LocalStorageStore")
local fireEventAsync = require("@root/Telemetry/fireEventAsync")
local getInstanceFromPath = require("@root/Common/getInstanceFromPath")
local getInstancePath = require("@root/Common/getInstancePath")

export type PinnedInstance = {
	path: string,
	instance: Instance?,
}

export type PinnedInstanceStore = {
	getPinnedInstances: () -> { PinnedInstance },
	isPinned: (instance: Instance) -> boolean,
	pin: (instance: Instance) -> (),
	unpin: (instance: Instance) -> (),
}

local function createPinnedInstanceStore(): PinnedInstanceStore
	local localStorageStore = LocalStorageStore.get()

	local getPinnedPaths = Charm.computed(function()
		local storage = localStorageStore.getStorage()
		return storage.pinnedInstancePaths or {}
	end)

	local function setPinnedPaths(update: (prev: { string }) -> { string })
		localStorageStore.setStorage(function(prev)
			return Sift.Dictionary.join(prev, {
				pinnedInstancePaths = update(prev.pinnedInstancePaths or {}),
			})
		end)
	end

	local getPinnedInstances = Charm.computed(function()
		local pinnedPaths = getPinnedPaths()

		return Sift.List.map(pinnedPaths, function(pinnedPath)
			return {
				path = pinnedPath,
				instance = getInstanceFromPath(pinnedPath),
			} :: PinnedInstance
		end)
	end)

	local function pin(instance: Instance)
		task.spawn(function()
			fireEventAsync({
				eventName = "NodePinned",
			})
		end)

		setPinnedPaths(function(prev)
			return Sift.List.append(prev, getInstancePath(instance))
		end)
	end

	local function unpin(instance: Instance)
		task.spawn(function()
			fireEventAsync({
				eventName = "NodeUnpinned",
			})
		end)

		setPinnedPaths(function(prev)
			return Sift.List.removeValue(prev, getInstancePath(instance))
		end)
	end

	local function isPinned(instance: Instance)
		return Sift.List.has(getPinnedPaths(), getInstancePath(instance))
	end

	return {
		pin = pin,
		unpin = unpin,
		isPinned = isPinned,
		getPinnedInstances = getPinnedInstances,
	}
end

return createPinnedInstanceStore
