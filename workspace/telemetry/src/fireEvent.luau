local HttpService = game:GetService("HttpService")

local types = require("@root/types")

type TelemetryEvent = types.TelemetryEvent

local function fireEvent(event: TelemetryEvent)
	HttpService:RequestAsync({
		Url = `{_G.BASE_URL}/telemetry`,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
		},
		Body = HttpService:JSONEncode(event),
	})
end

return fireEvent
