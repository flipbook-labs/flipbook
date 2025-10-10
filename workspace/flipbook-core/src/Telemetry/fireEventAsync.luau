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

	local res
	local success, err = pcall(function()
		res = HttpService:RequestAsync({
			Url = `{_G.BASE_URL}/telemetry`,
			Method = "POST",
			Headers = {
				["Content-Type"] = "application/json",
			},
			Body = HttpService:JSONEncode(body),
		})
	end)

	if not success then
		warn("fireEventAsync error", err)
		return
	end

	return res
end

return fireEventAsync
