local HttpService = game:GetService("HttpService")

local getAnonymizedUserId = require("@root/getAnonymizedUserId")
local types = require("@root/types")

type TelemetryEvent = types.TelemetryEvent

local function fireEventAsync(event: TelemetryEvent)
	local body = {
		event = event,
		anonymizedUserId = getAnonymizedUserId(),
	}

	return HttpService:RequestAsync({
		Url = `{_G.BASE_URL}/telemetry`,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
		},
		Body = HttpService:JSONEncode(body),
	})
end

return fireEventAsync
