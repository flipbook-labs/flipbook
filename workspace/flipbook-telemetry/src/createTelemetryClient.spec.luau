local HttpService = game:GetService("HttpService")

local JestGlobals = require("@pkg/JestGlobals")

local ConsentState = require("@root/ConsentState")
local createTelemetryClient = require("@root/createTelemetryClient")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

local function createHarness(initialValue: unknown?)
	local storedValue = initialValue
	local createdIds = 0
	local sent = {}

	local client = createTelemetryClient({
		context = {
			buildChannel = "test",
			buildHash = "abc123",
			buildVersion = "1.2.3",
		},
		storage = {
			read = function()
				return storedValue
			end,
			write = function(value)
				storedValue = value
			end,
		},
		transport = function(envelope)
			table.insert(sent, envelope)
		end,
	}, function()
		createdIds += 1
		return `anonymous-{createdIds}`
	end)

	return {
		client = client,
		getCreatedIds = function()
			return createdIds
		end,
		getSent = function()
			return sent
		end,
		getStoredValue = function()
			return storedValue
		end,
	}
end

describe("telemetry consent", function()
	test("does not create an identifier or send before consent", function()
		local harness = createHarness()

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
		local harness = createHarness()

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
		local harness = createHarness(HttpService:JSONEncode({
			version = 2,
			consent = ConsentState.Granted,
			anonymousId = "persisted-id",
		}))

		expect(harness.client.getConsent()).toBe(ConsentState.Granted)
		expect(harness.client.capture({ eventName = "StoryOpened" })).toBe(true)
		task.wait()

		expect(harness.getCreatedIds()).toBe(0)
		expect(harness.getSent()[1].anonymizedUserId).toBe("persisted-id")
	end)

	test("migrates an explicit legacy denial without creating an identifier", function()
		local storedValue
		local createdIds = 0
		local client = createTelemetryClient({
			context = {
				buildChannel = "test",
				buildHash = "abc123",
				buildVersion = "1.2.3",
			},
			legacyConsent = ConsentState.Denied,
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

		expect(client.getConsent()).toBe(ConsentState.Denied)
		expect(client.capture({ eventName = "AppOpened" })).toBe(false)
		expect(createdIds).toBe(0)
		expect(HttpService:JSONDecode(storedValue)).toEqual({
			version = 2,
			consent = ConsentState.Denied,
		})
	end)

	test("revoking consent removes the identifier and blocks later events", function()
		local harness = createHarness()
		harness.client.setConsent(ConsentState.Granted)

		harness.client.setConsent(ConsentState.Denied)

		expect(harness.client.capture({ eventName = "AppClosed" })).toBe(false)
		expect(HttpService:JSONDecode(harness.getStoredValue())).toEqual({
			version = 2,
			consent = ConsentState.Denied,
		})
	end)
end)
