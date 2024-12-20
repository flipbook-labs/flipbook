local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local LocalStorageContext = require("@root/Plugin/LocalStorageContext")
local getInstanceFromPath = require("@root/Common/getInstanceFromPath")
local getInstancePath = require("@root/Common/getInstancePath")
local usePrevious = require("@root/Common/usePrevious")

local useCallback = React.useCallback
local useState = React.useState
local useEffect = React.useEffect

local PINNED_INSTANCES_KEY = "pinnedInstancePaths"

export type PinnedInstance = {
	path: string,
	instance: Instance?,
}

local function usePinnedInstances(): (ModuleScript?, (storyModule: ModuleScript?) -> ())
	local localStorage = LocalStorageContext.use()

	local pinnedPaths, setPinnedPaths = useState(function()
		return localStorage.get(PINNED_INSTANCES_KEY) or {}
	end)
	local prevPinnedPaths = usePrevious(pinnedPaths)

	local pin = useCallback(function(instance: Instance)
		setPinnedPaths(function(prev)
			return Sift.List.append(prev, getInstancePath(instance))
		end)
	end, {})

	local unpin = useCallback(function(instance: Instance)
		setPinnedPaths(function(prev)
			return Sift.List.filter(prev, function(pinnedPath)
				return pinnedPath ~= getInstancePath(instance)
			end)
		end)
	end, {})

	local getPinnedInstances = useCallback(function(): { PinnedInstance }
		local pinnedInstances: { PinnedInstance } = {}

		for _, pinnedPath in pinnedPaths do
			table.insert(pinnedInstances, {
				path = pinnedPath,
				instance = getInstanceFromPath(pinnedPath),
			})
		end

		return pinnedInstances
	end, { pinnedPaths })

	local isPinned = useCallback(function(instance: Instance)
		return table.find(pinnedPaths, instance:GetFullName()) ~= nil
	end, { pinnedPaths })

	local togglePin = useCallback(function(instance: Instance)
		if isPinned(instance) then
			unpin(instance)
		else
			pin(instance)
		end
	end, { isPinned, unpin, pin })

	useEffect(function()
		if prevPinnedPaths and pinnedPaths ~= prevPinnedPaths then
			localStorage.set(PINNED_INSTANCES_KEY, pinnedPaths)
		end
	end, { localStorage.set, pinnedPaths, prevPinnedPaths })

	return {
		pin = pin,
		unpin = unpin,
		isPinned = isPinned,
		togglePin = togglePin,
		getPinnedInstances = getPinnedInstances,
	}
end

return usePinnedInstances
