local net = require("@std/net")

local logger = require("@scripts/lib/logger")
local types = require("@scripts/lib/posthog/types")

-- A dry run logs the request instead of sending it.
local function sendAsync(request: types.Request, dryRun: boolean)
	if dryRun then
		logger.info(`{request.metadata.method} {request.url}`)
		if request.metadata.body then
			logger.info(request.metadata.body)
		end
		return
	end

	local response = net.request(request.url, request.metadata)
	if not response.ok then
		error(`PostHog returned {response.status} for {request.url}\n{response.body}`, 0)
	end
end

return sendAsync
