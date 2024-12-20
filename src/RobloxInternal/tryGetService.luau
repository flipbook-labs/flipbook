local canAccess = require("@root/RobloxInternal/canAccess")

local function tryGetService(serviceName: string): Instance?
	local service: Instance?

	pcall(function()
		service = game:GetService(serviceName)
	end)

	if service and canAccess(service) then
		return service
	end

	-- Some services cannot be retrieved by GetService but still exist in the DM
	-- and can be retrieved by name.
	pcall(function()
		service = game:FindFirstChild(serviceName)
	end)

	if service and canAccess(service) then
		return service
	end

	return nil
end

return tryGetService
