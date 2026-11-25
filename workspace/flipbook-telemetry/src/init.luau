local HttpService = game:GetService("HttpService")

local ConsentState = require("@root/ConsentState")
local createTelemetryClient = require("@root/createTelemetryClient")
local types = require("@root/types")

export type ConsentDecision = types.ConsentDecision
export type ConsentState = types.ConsentState
export type TelemetryClient = types.TelemetryClient
export type TelemetryEnvelope = types.TelemetryEnvelope
export type TelemetryEvent = types.TelemetryEvent
export type TelemetryOptions = types.TelemetryOptions

return table.freeze({
	ConsentState = ConsentState,
	create = function(options: TelemetryOptions): TelemetryClient
		return createTelemetryClient(options, function()
			return HttpService:GenerateGUID(false)
		end)
	end,
})
