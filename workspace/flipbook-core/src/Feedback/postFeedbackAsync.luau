local getBuildInfo = require("@root/Common/getBuildInfo")
local getLocalUserId = require("@root/Telemetry/getLocalUserId")
local requestAsync = require("@root/Http/requestAsync")

local function postFeedbackAsync(title: string, body: string)
	local buildInfo = getBuildInfo()

	requestAsync(`{_G.BASE_URL}/feedback`, {
		method = "POST",
		body = {
			title = title,
			body = body,
			userId = tostring(getLocalUserId()),
			buildVersion = buildInfo.version,
			buildChannel = buildInfo.channel,
			buildHash = buildInfo.hash,
		},
	})
end

return postFeedbackAsync
