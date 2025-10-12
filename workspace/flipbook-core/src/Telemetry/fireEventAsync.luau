local HttpService = game:GetService("HttpService")

local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local getAnonymizedUserId = require("@root/Telemetry/getAnonymizedUserId")
local types = require("@root/Telemetry/types")

type TelemetryEvent = types.TelemetryEvent

local function fireEventAsync(event: TelemetryEvent)
	local userSettingsStore = UserSettingsStore.get(false)
	local userSettings = userSettingsStore.getStorage(false)

	if not userSettings.collectAnonymousUsageData then
		return
	end

	local body = {
		eventName = event.eventName,
		anonymizedUserId = getAnonymizedUserId(),
		buildVersion = _G.BUILD_VERSION,
		buildChannel = _G.BUILD_CHANNEL,
		buildHash = _G.BUILD_HASH,
	}

	local res
	local success, _err = pcall(function()
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
		-- TODO: Introduce a logging library so we can include this message
		-- without printing to the output all the time
		-- warn("failed to communicate with backend:", err)
		return
	end

	return res
end

return fireEventAsync
