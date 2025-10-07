local root = script:FindFirstAncestor("RoduxPresence")
local getDeepValue = require(root.getDeepValue)

return function(options)
	local keyPath = options.keyPath
	return function(state, userId)
		local byUserId = getDeepValue(state, keyPath .. ".byUserId")
		return byUserId[userId]
	end
end
