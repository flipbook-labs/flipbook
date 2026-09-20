local HttpService = game:GetService("HttpService")

local Charm = require("@pkg/Charm")

local ConsentState = require("@root/ConsentState")
local types = require("@root/types")

type ConsentDecision = types.ConsentDecision
type ConsentState = types.ConsentState
type TelemetryClient = types.TelemetryClient
type TelemetryEnvelope = types.TelemetryEnvelope
type TelemetryEvent = types.TelemetryEvent
type TelemetryOptions = types.TelemetryOptions

local STORAGE_VERSION = 2

type StoredConsent = {
	version: number,
	consent: ConsentDecision,
	anonymousId: string?,
}

local function decodeStoredConsent(value: unknown): StoredConsent?
	if typeof(value) ~= "string" then
		return nil
	end

	local success, decoded = pcall(function(): unknown
		return HttpService:JSONDecode(value)
	end)
	if not success or typeof(decoded) ~= "table" then
		return nil
	end

	local record = decoded :: { [string]: unknown }
	local consent = record.consent
	local anonymousId = record.anonymousId
	if record.version ~= STORAGE_VERSION then
		return nil
	end
	if consent ~= ConsentState.Granted and consent ~= ConsentState.Denied then
		return nil
	end
	if anonymousId ~= nil and typeof(anonymousId) ~= "string" then
		return nil
	end
	local parsedAnonymousId: string? = if typeof(anonymousId) == "string" then anonymousId else nil

	return {
		version = STORAGE_VERSION,
		consent = consent,
		anonymousId = parsedAnonymousId,
	}
end

local function getProperties(event: TelemetryEvent): { page: string }?
	if event.eventName == "PageChanged" then
		return event.properties
	end

	return nil
end

local function createTelemetryClient(options: TelemetryOptions, createAnonymousId: () -> string): TelemetryClient
	local storedConsent: StoredConsent?
	if not options.disabled and options.storage then
		local success, value = pcall(options.storage.read)
		if success then
			storedConsent = decodeStoredConsent(value)
		end
	end

	local initialConsent: ConsentState = ConsentState.Unknown
	local anonymousId: string?
	if storedConsent then
		initialConsent = storedConsent.consent
		anonymousId = storedConsent.anonymousId
	elseif options.legacyConsent == ConsentState.Denied then
		initialConsent = ConsentState.Denied
	end

	local getConsentSignal, setConsentSignal = Charm.signal(initialConsent)
	local function getConsent(): ConsentState
		return getConsentSignal() :: ConsentState
	end

	local function persist(consent: ConsentDecision)
		if options.storage == nil then
			return
		end

		local record: StoredConsent = {
			version = STORAGE_VERSION,
			consent = consent,
			anonymousId = anonymousId,
		}
		local success, encoded = pcall(function()
			return HttpService:JSONEncode(record)
		end)
		if success then
			pcall(options.storage.write, encoded)
		end
	end

	if not options.disabled and storedConsent == nil and initialConsent == ConsentState.Denied then
		persist(ConsentState.Denied)
	end

	local function setConsent(consent: ConsentDecision)
		if options.disabled then
			return
		end

		if consent == ConsentState.Granted then
			anonymousId = anonymousId or createAnonymousId()
		else
			anonymousId = nil
		end

		setConsentSignal(consent)
		persist(consent)
	end

	local function capture(event: TelemetryEvent): boolean
		if options.disabled or getConsent() ~= ConsentState.Granted then
			return false
		end

		local activeAnonymousId = anonymousId
		if activeAnonymousId == nil then
			activeAnonymousId = createAnonymousId()
			anonymousId = activeAnonymousId
			persist(ConsentState.Granted)
		end
		assert(activeAnonymousId ~= nil, "consented telemetry requires an anonymous identifier")

		local envelope: TelemetryEnvelope = {
			eventName = event.eventName,
			properties = getProperties(event),
			anonymizedUserId = activeAnonymousId,
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
		getConsent = getConsent,
		setConsent = setConsent,
	}
end

return createTelemetryClient
