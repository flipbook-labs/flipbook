local React = require("@pkg/React")
local Sift = require("@pkg/Sift")

local LocalStorageContext = require("@root/Plugin/LocalStorageContext")
local getInstanceFromFullName = require("@root/Common/getInstanceFromFullName")

local useCallback = React.useCallback
local useState = React.useState
local useEffect = React.useEffect

local PINNED_INSTANCES_KEY = "pinnedInstancePaths"

export type PinnedInstance = {
	path: string,
	instance: Instance?,
}

local function usePinnedInstances()
	local localStorage = LocalStorageContext.use()

	local pinnedPaths, setPinnedPaths = useState(function()
		return localStorage.get(PINNED_INSTANCES_KEY) or {}
	end)

	useEffect(function()
		localStorage.set(PINNED_INSTANCES_KEY, pinnedPaths)
	end, { pinnedPaths })

	local pin = useCallback(function(instance: Instance)
		setPinnedPaths(function(prev)
			return Sift.List.append(prev, instance:GetFullName())
		end)
	end, {})

	local unpin = useCallback(function(instance: Instance)
		setPinnedPaths(function(prev)
			return Sift.List.filter(prev, function(pinnedPath)
				return pinnedPath ~= instance:GetFullName()
			end)
		end)
	end, {})

	local getPinnedInstances = useCallback(function(): { PinnedInstance }
		local pinnedInstances: { PinnedInstance } = {}

		for _, pinnedPath in pinnedPaths do
			table.insert(pinnedInstances, {
				path = pinnedPath,
				instance = getInstanceFromFullName(pinnedPath),
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
	end, { isPinned, unpin, pin } :: { unknown })

	return {
		pin = pin,
		unpin = unpin,
		isPinned = isPinned,
		togglePin = togglePin,
		getPinnedInstances = getPinnedInstances,
	}
end

return usePinnedInstances
