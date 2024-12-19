local tryGetService = require("@root/RobloxInternal/tryGetService")

-- selene: allow(incorrect_standard_library_use)
type InternalSyncService = typeof(game:GetService("InternalSyncService"))

local InternalSyncService: InternalSyncService? = tryGetService("InternalSyncService")

local function getInternalSyncItems(): { InternalSyncItem }
	local internalSyncItems: { InternalSyncItem } = {}

	if InternalSyncService then
		for _, child in InternalSyncService:GetChildren() do
			if child:IsA("InternalSyncItem") then
				table.insert(internalSyncItems, child)
			end
		end
	end

	return internalSyncItems
end

return getInternalSyncItems
