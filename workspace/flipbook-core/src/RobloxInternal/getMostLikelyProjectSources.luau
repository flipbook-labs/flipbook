local Sift = require("@pkg/Sift")

local getInternalSyncItems = require("@root/RobloxInternal/getInternalSyncItems")

local PATTERNS = {
	"src.*$",
	"dist.*$",
	"modules.*$",
}

local function getMostLikelyProjectSources(): { Instance }
	local internalSyncItems = getInternalSyncItems()

	if #internalSyncItems > 0 then
		local sorted = Sift.List.sort(internalSyncItems, function(a: InternalSyncItem, b: InternalSyncItem)
			for _, pattern in PATTERNS do
				local aMatches = a.Path:match(pattern)
				local bMatches = b.Path:match(pattern)

				if aMatches and not bMatches then
					return true
				elseif bMatches and not aMatches then
					return false
				end
			end
			return nil
		end)

		return Sift.List.map(sorted, function(internalSyncItem)
			return internalSyncItem.Target
		end)
	end
	return {}
end

return getMostLikelyProjectSources
