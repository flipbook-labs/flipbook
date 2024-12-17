local HttpService = game:GetService("HttpService")

local React = require("@pkg/React")

local PluginContext = require("@root/Plugin/PluginContext")
local getInstanceFromFullName = require("@root/Common/getInstanceFromFullName")

local useContext = React.useContext
local useCallback = React.useCallback

local PINNED_INSTANCES_KEY = "pinnedInstancePaths"

export type PinnedInstance = {
	path: string,
	instance: Instance?,
}

local function usePinnedInstances(): (ModuleScript?, (storyModule: ModuleScript?) -> ())
	local plugin = useContext(PluginContext.Context)

	local readPinnedPathsFromDisk = useCallback(function(): { string }
		local data = plugin:GetSetting(PINNED_INSTANCES_KEY)
		if data then
			local json = HttpService:JSONDecode(data)
			if json then
				return json
			end
		end
		return {}
	end, { plugin })

	local writePinnedPathsToDisk = useCallback(function(pins: { string })
		local data = HttpService:JSONEncode(pins)
		plugin:SetSetting(PINNED_INSTANCES_KEY, data)
	end, { plugin })

	local pin = useCallback(function(instance: Instance)
		local pinnedPaths = readPinnedPathsFromDisk()

		table.insert(pinnedPaths, instance:GetFullName())

		writePinnedPathsToDisk(pinnedPaths)
	end, { readPinnedPathsFromDisk, writePinnedPathsToDisk })

	local unpin = useCallback(function(instance: Instance)
		local pinnedPaths = readPinnedPathsFromDisk()

		local index = table.find(pinnedPaths, instance:GetFullName())
		if index then
			table.remove(pinnedPaths, index)
		end

		writePinnedPathsToDisk(pinnedPaths)
	end, { readPinnedPathsFromDisk, writePinnedPathsToDisk })

	local getPinnedInstances = useCallback(function(): { PinnedInstance }
		local pinnedPaths = readPinnedPathsFromDisk()
		local pinnedInstances: { PinnedInstance } = {}

		for _, pinnedPath in pinnedPaths do
			table.insert(pinnedInstances, {
				path = pinnedPath,
				instance = getInstanceFromFullName(pinnedPath),
			})
		end

		return pinnedInstances
	end, { readPinnedPathsFromDisk })

	local togglePin = useCallback(function(instance: Instance)
		local pinnedPaths = readPinnedPathsFromDisk()
		local path = instance:GetFullName()

		local index = table.find(pinnedPaths, path)

		if index then
			table.remove(pinnedPaths, index)
		else
			table.insert(pinnedPaths, path)
		end

		writePinnedPathsToDisk(pinnedPaths)
	end, { readPinnedPathsFromDisk, writePinnedPathsToDisk })

	local isPinned = useCallback(function(instance: Instance)
		local pinnedPaths = readPinnedPathsFromDisk()
		return table.find(pinnedPaths, instance:GetFullName()) ~= nil
	end, { readPinnedPathsFromDisk })

	return {
		pin = pin,
		unpin = unpin,
		isPinned = isPinned,
		togglePin = togglePin,
		getPinnedInstances = getPinnedInstances,
	}
end

return usePinnedInstances
