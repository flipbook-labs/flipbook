local canAccess = require("@root/Permissions/canAccess")

local function tryGetService(serviceName: string): Instance?
	local service: Instance?

	pcall(function()
		service = game:GetService(serviceName)
	end)

	if service and canAccess(service) then
		return service
	else
		return nil
	end
end

return tryGetService
