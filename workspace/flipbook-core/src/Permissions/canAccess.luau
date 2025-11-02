local function canAccess(instance: Instance)
	local success = pcall(function()
		-- Attempt any use of the instance. If it throws an error, we assume
		-- that the current script context cannot access it
		return instance.Name
	end)

	return success
end

return canAccess
