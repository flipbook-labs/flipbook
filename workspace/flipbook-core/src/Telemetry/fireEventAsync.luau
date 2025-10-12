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
		properties = (event :: any).properties,
		anonymizedUserId = getAnonymizedUserId(),
		buildVersion = _G.BUILD_VERSION,
		buildChannel = _G.BUILD_CHANNEL,
		buildHash = _G.BUILD_HASH,
	}

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

	-- TODO: Introduce a logging library so we can include these messages
	-- without printing to the output all the time
	if not success then
		warn("failed to communicate with backend:", err)
	end
	if not res.Success then
		warn("failed sending event to basckend:", res.StatusMessage)
	end

	return res
end

return fireEventAsync
