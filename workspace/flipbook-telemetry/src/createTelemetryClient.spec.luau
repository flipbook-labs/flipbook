local JestGlobals = require("@pkg/JestGlobals")

local createTelemetryClient = require("@root/createTelemetryClient")

local describe = JestGlobals.describe
local expect = JestGlobals.expect
local test = JestGlobals.test

local function createHarness(isEnabled: boolean)
	local idRequests = 0
	local sent = {}

	local client = createTelemetryClient({
		context = {
			buildChannel = "test",
			buildHash = "abc123",
			buildVersion = "1.2.3",
		},
		isEnabled = function()
			return isEnabled
		end,
		getAnonymousId = function()
			idRequests += 1
			return "anonymous-id"
		end,
		transport = function(envelope)
			table.insert(sent, envelope)
		end,
	})

	return {
		client = client,
		getIdRequests = function()
			return idRequests
		end,
		getSent = function()
			return sent
		end,
	}
end

describe("telemetry client", function()
	test("does not identify or send while disabled", function()
		local harness = createHarness(false)

		expect(harness.client.capture({ eventName = "AppOpened" })).toBe(false)
		task.wait()

		expect(harness.getIdRequests()).toBe(0)
		expect(#harness.getSent()).toBe(0)
	end)

	test("sends the envelope the backend expects while enabled", function()
		local harness = createHarness(true)

		expect(harness.client.capture({
			eventName = "PageChanged",
			properties = {
				page = "Settings",
			},
		})).toBe(true)
		task.wait()

		expect(harness.getSent()).toEqual({
			{
				anonymizedUserId = "anonymous-id",
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

	test("omits properties from events that do not define them", function()
		local harness = createHarness(true)

		harness.client.capture({ eventName = "StoryOpened" })
		task.wait()

		expect(harness.getSent()[1].properties).toBeUndefined()
	end)
end)
