local HttpService = game:GetService("HttpService")

local getAnonymizedUserId = require("@root/Telemetry/getAnonymizedUserId")
local types = require("@root/Telemetry/types")

type TelemetryEvent = types.TelemetryEvent

local function fireEventAsync(event: TelemetryEvent)
	local body = {
		event = event,
		anonymizedUserId = getAnonymizedUserId(),
	}

	print("fireEventAsync", event.eventName)

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
