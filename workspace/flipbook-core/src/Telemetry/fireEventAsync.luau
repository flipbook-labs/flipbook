local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local getAnonymizedUserId = require("@root/Telemetry/getAnonymizedUserId")
local logger = require("@root/logger")
local requestAsync = require("@root/Http/requestAsync")
local types = require("@root/Telemetry/types")

type TelemetryEvent = types.TelemetryEvent

local function fireEventAsync(event: TelemetryEvent)
	local userSettingsStore = UserSettingsStore.get()
	local userSettings = userSettingsStore.getStorage()

	if not userSettings.collectAnonymousUsageData then
		return
	end

	-- Only some telemetry events have properties, and Luau can't read a field
	-- that only some members of the event union have.
	-- lute-lint-ignore(no_any)
	local properties = (event :: any).properties

	local body = {
		eventName = event.eventName,
		properties = properties,
		anonymizedUserId = getAnonymizedUserId(),
		buildVersion = _G.BUILD_VERSION,
		buildChannel = _G.BUILD_CHANNEL,
		buildHash = _G.BUILD_HASH,
	}

	logger:Info(`firing event {event.eventName}`)

	return requestAsync(`{_G.BASE_URL}/telemetry`, {
		method = "POST",
		body = body,
	})
end

return fireEventAsync
