local HttpService = game:GetService("HttpService")

local JestGlobals = require("@pkg/JestGlobals")

local ConsentState = require("@root/ConsentState")
local createTelemetryClient = require("@root/createTelemetryClient")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

type HarnessOptions = {
	readDelay: number?,
}

local function createHarness(initialValue: unknown?, harnessOptions: HarnessOptions?)
	local storedValue = initialValue
	local createdIds = 0
	local sent = {}
	local warnings = {}
	local shouldFailWrites = false
	local readDelay = if harnessOptions then harnessOptions.readDelay else nil

	local client = createTelemetryClient({
		context = {
			buildChannel = "test",
			buildHash = "abc123",
			buildVersion = "1.2.3",
		},
		storage = {
			read = function()
				if readDelay then
					task.wait(readDelay)
				end
				return storedValue
			end,
			write = function(value)
				if shouldFailWrites then
					error("disk unavailable")
				end
				storedValue = value
			end,
		},
		transport = function(envelope)
			table.insert(sent, envelope)
		end,
		warn = function(message)
			table.insert(warnings, message)
		end,
	}, function()
		createdIds += 1
		return `anonymous-{createdIds}`
	end)

	return {
		client = client,
		failWrites = function()
			shouldFailWrites = true
		end,
		getCreatedIds = function()
			return createdIds
		end,
		getSent = function()
			return sent
		end,
		getStoredValue = function()
			return storedValue
		end,
		getWarnings = function()
			return warnings
		end,
	}
end

local function createLoadedHarness(initialValue: unknown?)
	local harness = createHarness(initialValue)
	harness.client.waitForLoaded()
	return harness
end

local GRANTED_RECORD = HttpService:JSONEncode({
	version = 2,
	consent = ConsentState.Granted,
	anonymousId = "persisted-id",
})

describe("telemetry consent", function()
	test("does not create an identifier or send before consent", function()
		local harness = createLoadedHarness()

		expect(harness.client.getConsent()).toBe(ConsentState.Unknown)
		expect(harness.client.capture({ eventName = "AppOpened" })).toBe(false)
		expect(harness.getCreatedIds()).toBe(0)
		expect(#harness.getSent()).toBe(0)
	end)

	test("keeps disabled clients inert even when consent is requested", function()
		local storageReads = 0
		local createdIds = 0
		local sentEvents = 0
		local client = createTelemetryClient({
			context = {
				buildChannel = "test",
				buildHash = "abc123",
				buildVersion = "1.2.3",
			},
			disabled = true,
			storage = {
				read = function()
					storageReads += 1
					return nil
				end,
				write = function() end,
			},
			transport = function()
				sentEvents += 1
			end,
		}, function()
			createdIds += 1
			return "unexpected"
		end)

		client.setConsent(ConsentState.Granted)

		expect(client.getConsent()).toBe(ConsentState.Unknown)
		expect(client.capture({ eventName = "AppOpened" })).toBe(false)
		expect(storageReads).toBe(0)
		expect(createdIds).toBe(0)
		expect(sentEvents).toBe(0)
	end)

	test("creates an identifier only after consent and sends the existing envelope", function()
		local harness = createLoadedHarness()

		harness.client.setConsent(ConsentState.Granted)
		expect(harness.client.capture({
			eventName = "PageChanged",
			properties = {
				page = "Settings",
			},
		})).toBe(true)
		task.wait()

		expect(harness.getCreatedIds()).toBe(1)
		expect(harness.getSent()).toEqual({
			{
				anonymizedUserId = "anonymous-1",
				buildChannel = "test",
				buildHash = "abc123",
				buildVersion = "1.2.3",
				eventName = "PageChanged",
				properties = {
					page = "Settings",
				},
			},
		})
	end)

	test("restores versioned consent and its anonymous identifier", function()
		local harness = createLoadedHarness(GRANTED_RECORD)

		expect(harness.client.getConsent()).toBe(ConsentState.Granted)
		expect(harness.client.capture({ eventName = "StoryOpened" })).toBe(true)
		task.wait()

		expect(harness.getCreatedIds()).toBe(0)
		expect(harness.getSent()[1].anonymizedUserId).toBe("persisted-id")
	end)

	test("migrates an explicit legacy denial without creating an identifier", function()
		local storedValue: string?
		local createdIds = 0
		local client = createTelemetryClient({
			context = {
				buildChannel = "test",
				buildHash = "abc123",
				buildVersion = "1.2.3",
			},
			readLegacyConsent = function()
				return ConsentState.Denied
			end,
			storage = {
				read = function()
					return nil
				end,
				write = function(value)
					storedValue = value
				end,
			},
			transport = function() end,
		}, function()
			createdIds += 1
			return "unexpected"
		end)
		client.waitForLoaded()

		expect(client.getConsent()).toBe(ConsentState.Denied)
		expect(client.capture({ eventName = "AppOpened" })).toBe(false)
		expect(createdIds).toBe(0)
		expect(HttpService:JSONDecode(storedValue)).toEqual({
			version = 2,
			consent = ConsentState.Denied,
		})
	end)

	test("revoking consent removes the identifier and blocks later events", function()
		local harness = createLoadedHarness()
		harness.client.setConsent(ConsentState.Granted)

		harness.client.setConsent(ConsentState.Denied)

		expect(harness.client.capture({ eventName = "AppClosed" })).toBe(false)
		expect(HttpService:JSONDecode(harness.getStoredValue())).toEqual({
			version = 2,
			consent = ConsentState.Denied,
		})
	end)

	test("drops events captured while consent is still loading", function()
		local harness = createHarness(GRANTED_RECORD, { readDelay = 0.1 })

		expect(harness.client.getIsLoading()).toBe(true)
		expect(harness.client.capture({ eventName = "AppOpened" })).toBe(false)

		harness.client.waitForLoaded()
		task.wait()

		expect(harness.client.getConsent()).toBe(ConsentState.Granted)
		expect(#harness.getSent()).toBe(0)
	end)

	test("refuses consent changes until consent has loaded", function()
		local harness = createHarness(nil, { readDelay = 0.1 })

		expect(harness.client.setConsent(ConsentState.Granted)).toBe(false)

		harness.client.waitForLoaded()

		expect(harness.client.getConsent()).toBe(ConsentState.Unknown)
		expect(harness.getCreatedIds()).toBe(0)
	end)

	test("reports a grant that fails to save and keeps collection off", function()
		local harness = createLoadedHarness()
		harness.failWrites()

		expect(harness.client.setConsent(ConsentState.Granted)).toBe(false)

		expect(harness.client.getConsent()).toBe(ConsentState.Unknown)
		expect(harness.client.capture({ eventName = "AppOpened" })).toBe(false)
		expect(#harness.getWarnings()).toBe(1)
	end)

	test("blocks collection when a revocation fails to save", function()
		local harness = createLoadedHarness(GRANTED_RECORD)
		harness.failWrites()

		expect(harness.client.setConsent(ConsentState.Denied)).toBe(false)

		expect(harness.client.getConsent()).toBe(ConsentState.Denied)
		expect(harness.client.capture({ eventName = "AppClosed" })).toBe(false)
		expect(harness.getStoredValue()).toBe(GRANTED_RECORD)
		expect(#harness.getWarnings()).toBe(1)
	end)
end)
