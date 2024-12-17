local function tryGetService(serviceName: string): Instance
	local service

	pcall(function()
		service = game:GetService(serviceName)
	end)

	if service then
		return service
	end

	-- Some services cannot be retrieved by GetService but still exist in the DM
	-- and can be retrieved by name.
	pcall(function()
		service = game:FindFirstChild(serviceName)
	end)

	return service
end

return tryGetService
