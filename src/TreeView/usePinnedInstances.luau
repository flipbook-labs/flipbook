local React = require("@pkg/React")
local Sift = require("@pkg/Sift")
local SignalsReact = require("@rbxpkg/SignalsReact")

local LocalStorageStore = require("@root/Plugin/LocalStorageStore")
local getInstanceFromFullName = require("@root/Common/getInstanceFromFullName")
local usePrevious = require("@root/Common/usePrevious")

local useCallback = React.useCallback
local useState = React.useState
local useEffect = React.useEffect
local useSignalState = SignalsReact.useSignalState

export type PinnedInstance = {
	path: string,
	instance: Instance?,
}

local function usePinnedInstances()
	local localStorageStore = useSignalState(LocalStorageStore.get)
	local localStorage = useSignalState(localStorageStore.getStorage)

	local pinnedPaths, setPinnedPaths = useState(function()
		return localStorage.pinnedInstancePaths or {} :: { string }
	end)

	local prevPinnedPaths = usePrevious(pinnedPaths)

	useEffect(function()
		if pinnedPaths ~= prevPinnedPaths then
			localStorageStore.setStorage(function(prev)
				return Sift.Dictionary.join(prev, {
					pinnedInstancePaths = pinnedPaths,
				})
			end)
		end
	end, { pinnedPaths, prevPinnedPaths, localStorageStore } :: { unknown })

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
