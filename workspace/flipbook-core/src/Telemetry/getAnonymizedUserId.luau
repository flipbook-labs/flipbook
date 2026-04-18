local sha256 = require("@pkg/sha256")

local getLocalUserId = require("@root/Telemetry/getLocalUserId")

--[[
	The events we send to the backend need some persistent identifier so we can
	group them by the user they come from. However, we do not collect PII so we
	first need to anonymize the UserId before sending it off. That's what this
	function is for.
]]
local function getAnonymizedUserId(): string
	local plainUserId = getLocalUserId()
	local hash = sha256(tostring(plainUserId))
	return hash
end

return getAnonymizedUserId
