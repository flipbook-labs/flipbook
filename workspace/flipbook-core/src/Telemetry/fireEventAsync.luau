local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local getAnonymizedUserId = require("@root/Telemetry/getAnonymizedUserId")
local logging = require("@root/logging")
local requestAsync = require("@root/Http/requestAsync")
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

	logging:Info(`firing event {event.eventName}`)

	return requestAsync(`{_G.BASE_URL}/telemetry`, {
		method = "POST",
		body = body,
	})
end

return fireEventAsync
