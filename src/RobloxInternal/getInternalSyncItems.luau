local tryGetService = require("@root/RobloxInternal/tryGetService")

-- selene: allow(incorrect_standard_library_use)
type FileSyncService = typeof(game:GetService("FileSyncService"))

local FileSyncService: FileSyncService? = tryGetService("FileSyncService")

local function getInternalSyncItems(): { InternalSyncItem }
	local internalSyncItems: { InternalSyncItem } = {}

	if FileSyncService then
		for _, child in FileSyncService:GetChildren() do
			if child:IsA("InternalSyncItem") then
				table.insert(internalSyncItems, child)
			end
		end
	end

	return internalSyncItems
end

return getInternalSyncItems
