local types = require("@root/types")

type TelemetryClient = types.TelemetryClient
type TelemetryEnvelope = types.TelemetryEnvelope
type TelemetryEvent = types.TelemetryEvent
type TelemetryOptions = types.TelemetryOptions

local function getProperties(event: TelemetryEvent): { page: string }?
	if event.eventName == "PageChanged" then
		return event.properties
	end

	return nil
end

local function createTelemetryClient(options: TelemetryOptions): TelemetryClient
	local function capture(event: TelemetryEvent): boolean
		if not options.isEnabled() then
			return false
		end

		local envelope: TelemetryEnvelope = {
			eventName = event.eventName,
			properties = getProperties(event),
			anonymizedUserId = options.getAnonymousId(),
			buildVersion = options.context.buildVersion,
			buildChannel = options.context.buildChannel,
			buildHash = options.context.buildHash,
		}

		task.spawn(function()
			options.transport(envelope)
		end)

		return true
	end

	return {
		capture = capture,
	}
end

return createTelemetryClient
