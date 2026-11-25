local JestGlobals = require("@pkg/JestGlobals")
local ReactRoblox = require("@pkg/ReactRoblox")
local Telemetry = require(script.Parent.Parent.Parent["flipbook-telemetry"])

local CommonTypes = require("@root/Common/types")

local ConsentState = Telemetry.ConsentState
local act = ReactRoblox.act
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local test = JestGlobals.test

type Pluginlike = CommonTypes.Pluginlike
type TelemetryClient = Telemetry.TelemetryClient

-- Required in beforeEach, after it mocks the modules they depend on.
local FlipbookStoreContext: typeof(require("@root/FlipbookStore/FlipbookStoreContext"))
local createFlipbookPlugin: typeof(require("./createFlipbookPlugin"))

local flipbookPlugin: { destroy: () -> () }?
local widget: DockWidgetPluginGui
local mockAppTelemetry: TelemetryClient?
local mockSentEvents: { string }

beforeEach(function()
	mockAppTelemetry = nil
	mockSentEvents = {}

	jest.mock(script.Parent.Parent.Http.requestAsync, function()
		return function(_url: string, options: { body: { eventName: string } })
			table.insert(mockSentEvents, options.body.eventName)
			return nil
		end
	end)

	-- The agent gateway is published under CoreGui, which specs can't access.
	jest.mock(script.Parent.Parent.Parent["flipbook-agents"], function()
		return {
			createAgentController = function()
				return {}
			end,
			createAgentGateway = function()
				return function() end
			end,
		}
	end)

	-- Stands in for Flipbook's UI and keeps the telemetry client that the
	-- consent dialog and Settings would use.
	jest.mock(script.Parent.Parent.FlipbookApp, function()
		return function()
			mockAppTelemetry = FlipbookStoreContext.use().telemetry
			return nil
		end
	end)

	FlipbookStoreContext = require("@root/FlipbookStore/FlipbookStoreContext")
	createFlipbookPlugin = require("./createFlipbookPlugin")

	-- Only Studio can create a DockWidgetPluginGui. A ScreenGui has the same
	-- Enabled property.
	widget = (Instance.new("ScreenGui") :: Instance) :: DockWidgetPluginGui
	widget.Enabled = false
end)

local function createPlugin(): TelemetryClient
	local settings: { [string]: unknown } = {}
	local plugin: Pluginlike = {
		GetSetting = function(_self, key: string)
			return settings[key]
		end,
		SetSetting = function(_self, key: string, value: unknown)
			settings[key] = value
		end,
	} :: Pluginlike

	act(function()
		flipbookPlugin = createFlipbookPlugin(plugin, widget)
	end)
	assert(mockAppTelemetry, "the app did not mount")

	return mockAppTelemetry
end

local function destroyPlugin()
	local mountedPlugin = flipbookPlugin
	if mountedPlugin == nil then
		return
	end

	flipbookPlugin = nil
	act(function()
		mountedPlugin.destroy()
	end)
end

local function setWidgetOpen(isOpen: boolean)
	act(function()
		widget.Enabled = isOpen
		-- Roblox can defer signals, so this gives the plugin time to see the change.
		task.wait()
	end)
end

afterEach(function()
	destroyPlugin()
	widget:Destroy()
end)

test("sends nothing about the widget before consent is granted", function()
	createPlugin()

	setWidgetOpen(true)
	setWidgetOpen(false)

	expect(mockSentEvents).toEqual({})
end)

test("reports the widget opening and closing once the app grants consent", function()
	local appTelemetry = createPlugin()
	appTelemetry.setConsent(ConsentState.Granted)

	setWidgetOpen(true)
	setWidgetOpen(false)

	expect(mockSentEvents).toEqual({ "AppOpened", "AppClosed" })
end)

test("stops reporting the widget when the app revokes consent", function()
	local appTelemetry = createPlugin()
	appTelemetry.setConsent(ConsentState.Granted)
	setWidgetOpen(true)

	appTelemetry.setConsent(ConsentState.Denied)
	setWidgetOpen(false)

	expect(mockSentEvents).toEqual({ "AppOpened" })
end)

test("reports an open widget closing when the plugin is destroyed", function()
	local appTelemetry = createPlugin()
	appTelemetry.setConsent(ConsentState.Granted)
	setWidgetOpen(true)

	destroyPlugin()

	expect(mockSentEvents).toEqual({ "AppOpened", "AppClosed" })
end)
