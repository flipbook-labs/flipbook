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
	local isDisabled = options.disabled == true
	local storage = if isDisabled then nil else options.storage
	local readLegacyConsent = if isDisabled then nil else options.readLegacyConsent

	local getConsentSignal, setConsentSignal = Charm.signal(ConsentState.Unknown :: ConsentState)
	local getIsLoadingSignal, setIsLoading = Charm.signal(storage ~= nil or readLegacyConsent ~= nil)
	local anonymousId: string?

	local function getConsent(): ConsentState
		return getConsentSignal() :: ConsentState
	end

	local function getIsLoading(): boolean
		return getIsLoadingSignal() :: boolean
	end

	local function warn(message: string)
		if options.warn then
			options.warn(message)
		end
	end

	local function persist(consent: ConsentDecision): boolean
		if storage == nil then
			return true
		end

		local record: StoredConsent = {
			version = STORAGE_VERSION,
			consent = consent,
			anonymousId = anonymousId,
		}
		local success, err = pcall(function()
			storage.write(HttpService:JSONEncode(record))
		end)
		if not success then
			warn(`failed to save telemetry consent: {err}`)
		end

		return success
	end

	local function load()
		local storedConsent: StoredConsent?
		if storage then
			local success, value = pcall(storage.read)
			if success then
				storedConsent = decodeStoredConsent(value)
			else
				warn(`failed to read telemetry consent: {value}`)
			end
		end

		if storedConsent then
			anonymousId = storedConsent.anonymousId
			setConsentSignal(storedConsent.consent)
		elseif readLegacyConsent then
			local success, legacyConsent = pcall(readLegacyConsent)
			if success and legacyConsent == ConsentState.Denied then
				setConsentSignal(ConsentState.Denied)
				persist(ConsentState.Denied)
			end
		end

		setIsLoading(false)
	end

	local function waitForLoaded()
		while getIsLoading() do
			task.wait()
		end
	end

	local function setConsent(consent: ConsentDecision): boolean
		if isDisabled then
			return false
		end
		if getIsLoading() then
			warn("cannot change telemetry consent before it finishes loading")
			return false
		end

		local previousConsent = getConsent()
		local previousAnonymousId = anonymousId
		if consent == ConsentState.Granted then
			anonymousId = anonymousId or createAnonymousId()
		else
			anonymousId = nil
		end
		setConsentSignal(consent)

		local saved = persist(consent)
		if not saved and consent == ConsentState.Granted then
			anonymousId = previousAnonymousId
			setConsentSignal(previousConsent)
		end

		return saved
	end

	local function capture(event: TelemetryEvent): boolean
		if isDisabled or getConsent() ~= ConsentState.Granted then
			return false
		end

		local activeAnonymousId = anonymousId
		if activeAnonymousId == nil then
			activeAnonymousId = createAnonymousId()
			anonymousId = activeAnonymousId
			task.spawn(persist, ConsentState.Granted)
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

	if getIsLoading() then
		task.spawn(load)
	end

	return {
		capture = capture,
		getConsent = getConsent,
		getIsLoading = getIsLoading,
		setConsent = setConsent,
		waitForLoaded = waitForLoaded,
	}
end

return createTelemetryClient
