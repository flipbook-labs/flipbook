local createTelemetryClient = require("@root/createTelemetryClient")
local types = require("@root/types")

export type TelemetryClient = types.TelemetryClient
export type TelemetryEnvelope = types.TelemetryEnvelope
export type TelemetryEvent = types.TelemetryEvent
export type TelemetryOptions = types.TelemetryOptions

return table.freeze({
	create = createTelemetryClient,
})
