local HttpService = game:GetService("HttpService")

local JestGlobals = require("@pkg/JestGlobals")
local Telemetry = require(script.Parent.Parent.Parent["flipbook-telemetry"])

local AppMode = require("@root/Enums/AppMode")
local MockPlugin = require("@root/Testing/MockPlugin")
local createTelemetry = require("./createTelemetry")

local expect = JestGlobals.expect
local test = JestGlobals.test

local function createPluginWithLegacySettings(settings: unknown)
	local plugin = MockPlugin.new()
	plugin:SetSetting("FlipbookUserSettings", HttpService:JSONEncode(settings))
	return plugin
end

test("restores an opt-out saved by the old settings", function()
	local plugin = createPluginWithLegacySettings({
		collectAnonymousUsageData = false,
	})

	local telemetry = createTelemetry(AppMode.PluginWidget, plugin)
	telemetry.waitForLoaded()

	expect(telemetry.getConsent()).toBe(Telemetry.ConsentState.Denied)
	expect(telemetry.capture({ eventName = "AppOpened" })).toBe(false)

	local stored = HttpService:JSONDecode(plugin:GetSetting("FlipbookTelemetry"))
	expect(stored.consent).toBe(Telemetry.ConsentState.Denied)
end)

test("asks again when the old settings allowed collection", function()
	local plugin = createPluginWithLegacySettings({
		collectAnonymousUsageData = true,
	})

	local telemetry = createTelemetry(AppMode.PluginWidget, plugin)
	telemetry.waitForLoaded()

	expect(telemetry.getConsent()).toBe(Telemetry.ConsentState.Unknown)
	expect(plugin:GetSetting("FlipbookTelemetry")).toBeNil()
end)

test("asks when the old settings can't be read", function()
	local plugin = MockPlugin.new()
	plugin:SetSetting("FlipbookUserSettings", "not json")

	local telemetry = createTelemetry(AppMode.PluginWidget, plugin)
	telemetry.waitForLoaded()

	expect(telemetry.getConsent()).toBe(Telemetry.ConsentState.Unknown)
end)

test("prefers a saved decision over the old settings", function()
	local plugin = createPluginWithLegacySettings({
		collectAnonymousUsageData = false,
	})

	local first = createTelemetry(AppMode.PluginWidget, plugin)
	first.waitForLoaded()
	expect(first.setConsent(Telemetry.ConsentState.Granted)).toBe(true)

	local second = createTelemetry(AppMode.PluginWidget, plugin)
	second.waitForLoaded()

	expect(second.getConsent()).toBe(Telemetry.ConsentState.Granted)
end)
