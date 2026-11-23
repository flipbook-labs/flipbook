local getBuildInfo = require("@root/Common/getBuildInfo")
local getLocalUserId = require("@root/Telemetry/getLocalUserId")
local requestAsync = require("@root/Http/requestAsync")

--[[
	Sends feedback to the backend, which files it as a GitHub issue. Returns
	whether the backend accepted it. `requestAsync` returns nil when the request
	can't be sent at all, such as when HTTP requests are disabled, so that counts
	as a failure too.
]]
local function postFeedbackAsync(title: string, body: string): boolean
	local buildInfo = getBuildInfo()

	local res = requestAsync(`{_G.BASE_URL}/feedback`, {
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

	return res ~= nil and res.Success
end

return postFeedbackAsync
