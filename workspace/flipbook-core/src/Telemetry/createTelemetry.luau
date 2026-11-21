local Telemetry = require(script.Parent.Parent.Parent["flipbook-telemetry"])

local UserSettingsStore = require("@root/UserSettings/UserSettingsStore")
local getAnonymizedUserId = require("@root/Telemetry/getAnonymizedUserId")
local getBuildInfo = require("@root/Common/getBuildInfo")
local logger = require("@root/logger")
local requestAsync = require("@root/Http/requestAsync")

type TelemetryClient = Telemetry.TelemetryClient
type TelemetryEnvelope = Telemetry.TelemetryEnvelope

local function createTelemetry(): TelemetryClient
	local buildInfo = getBuildInfo()

	return Telemetry.create({
		context = {
			buildChannel = buildInfo.channel,
			buildHash = buildInfo.hash,
			buildVersion = buildInfo.version,
		},
		isEnabled = function()
			return UserSettingsStore.get().getStorage().collectAnonymousUsageData
		end,
		getAnonymousId = getAnonymizedUserId,
		transport = function(envelope: TelemetryEnvelope)
			logger:Info(`firing event {envelope.eventName}`)
			requestAsync(`{_G.BASE_URL}/telemetry`, {
				method = "POST",
				body = envelope,
			})
		end,
	})
end

return createTelemetry
