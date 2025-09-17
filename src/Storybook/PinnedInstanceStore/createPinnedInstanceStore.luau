local Sift = require("@pkg/Sift")
local Signals = require("@rbxpkg/Signals")

local LocalStorageStore = require("@root/Plugin/LocalStorageStore")
local getInstanceFromFullName = require("@root/Common/getInstanceFromFullName")

export type PinnedInstance = {
	path: string,
	instance: Instance?,
}

export type PinnedInstanceStore = {
	getPinnedInstances: Signals.getter<{ PinnedInstance }>,
	isPinned: (instance: Instance) -> boolean,
	pin: (instance: Instance) -> (),
	unpin: (instance: Instance) -> (),

	dispose: () -> (),
}

local function createPinnedInstanceStore(parentScope: Signals.scope): PinnedInstanceStore
	local getPinnedPaths, setPinnedPaths = Signals.createSignal({} :: { string })
	local getPinnedInstances, setPinnedInstances = Signals.createSignal({} :: { PinnedInstance })

	local localStorageStore = LocalStorageStore.get(parentScope)

	local function pin(instance: Instance)
		setPinnedPaths(function(prev)
			return Sift.List.append(prev, instance:GetFullName())
		end)
	end

	local function unpin(instance: Instance)
		setPinnedPaths(function(prev)
			return Sift.List.removeValue(prev, instance:GetFullName())
		end)
	end

	local function isPinned(instance: Instance)
		return Sift.List.has(getPinnedPaths(false), instance:GetFullName())
	end

	local dispose = Signals.createEffect(function(scope)
		local pinnedPaths = getPinnedPaths(scope)

		setPinnedInstances(Sift.List.map(pinnedPaths, function(pinnedPath)
			return {
				path = pinnedPath,
				instance = getInstanceFromFullName(pinnedPath),
			} :: PinnedInstance
		end))

		localStorageStore.setStorage(function(prev)
			return Sift.Dictionary.join(prev, {
				pinnedInstancePaths = pinnedPaths,
			})
		end)
	end)

	return {
		pin = pin,
		unpin = unpin,
		isPinned = isPinned,
		getPinnedInstances = getPinnedInstances,

		dispose = dispose,
	}
end

return createPinnedInstanceStore
