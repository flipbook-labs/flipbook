local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")
local Telemetry = require(script.Parent.Parent.Parent["flipbook-telemetry"])

local AppMode = require("@root/Enums/AppMode")
local CommonTypes = require("@root/Common/types")
local createFoundationStub = require("@root/Testing/createFoundationStub")

local ConsentState = Telemetry.ConsentState
local act = ReactRoblox.act
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local test = JestGlobals.test

type AppMode = AppMode.AppMode
type Pluginlike = CommonTypes.Pluginlike

-- Required in beforeEach, after requestAsync and Foundation are mocked.
local FlipbookStoreContext: typeof(require("@root/FlipbookStore/FlipbookStoreContext"))
local TelemetrySettingRow: typeof(require("./TelemetrySettingRow"))
local createFlipbookStore: typeof(require("@root/FlipbookStore/createFlipbookStore"))

local foundation = createFoundationStub()
local settings: { [string]: unknown }
local canSave: boolean
local plugin: Pluginlike
local root: ReactRoblox.RootType
local mockSentEvents: { string }

beforeEach(function()
	mockSentEvents = {}

	jest.mock(script.Parent.Parent.Http.requestAsync, function()
		return function(_url: string, options: { body: { eventName: string } })
			table.insert(mockSentEvents, options.body.eventName)
			return nil
		end
	end)

	jest.mock(script.Parent.Parent.Parent.Parent.RobloxPackages.Foundation, function()
		return foundation.components
	end)

	FlipbookStoreContext = require("@root/FlipbookStore/FlipbookStoreContext")
	TelemetrySettingRow = require("./TelemetrySettingRow")
	createFlipbookStore = require("@root/FlipbookStore/createFlipbookStore")

	settings = {}
	canSave = true
	plugin = {
		GetSetting = function(_self, key: string)
			return settings[key]
		end,
		SetSetting = function(_self, key: string, value: unknown)
			if not canSave then
				error("the plugin can't save settings")
			end
			settings[key] = value
		end,
	} :: Pluginlike

	root = ReactRoblox.createRoot(Instance.new("Folder"))
end)

afterEach(function()
	act(function()
		root:unmount()
	end)
end)

local function renderRow(mode: AppMode?)
	local store = createFlipbookStore({
		mode = mode or AppMode.PluginWidget,
		plugin = plugin,
	})

	act(function()
		root:render(React.createElement(FlipbookStoreContext.Provider, {
			store = store,
		}, {
			Row = React.createElement(TelemetrySettingRow),
		}))
	end)

	return store.telemetry
end

local function getCheckbox()
	return foundation.getMountedProps("Checkbox")[1]
end

local function setChecked(isChecked: boolean)
	act(function()
		getCheckbox().onActivated(isChecked)
	end)
end

test("starts unchecked when no choice is saved", function()
	renderRow()

	expect(getCheckbox().isChecked).toBe(false)
	expect(getCheckbox().isDisabled).toBe(false)
end)

test("can't be changed while consent is loading", function()
	plugin.GetSetting = function()
		return coroutine.yield()
	end

	renderRow()

	expect(getCheckbox().isDisabled).toBe(true)
end)

test("shares usage data when checked", function()
	local telemetry = renderRow()

	setChecked(true)

	expect(telemetry.getConsent()).toBe(ConsentState.Granted)
	expect(getCheckbox().isChecked).toBe(true)
	expect(mockSentEvents).toEqual({ "TelemetryOptedIn" })
end)

test("stops sharing usage data when unchecked", function()
	local telemetry = renderRow()
	setChecked(true)

	setChecked(false)

	expect(telemetry.getConsent()).toBe(ConsentState.Denied)
	expect(getCheckbox().isChecked).toBe(false)
	expect(mockSentEvents).toEqual({ "TelemetryOptedIn" })
	expect(telemetry.capture({ eventName = "AppOpened" })).toBe(false)
end)

test("stays unchecked when sharing can't be saved", function()
	local telemetry = renderRow()

	canSave = false
	setChecked(true)

	expect(telemetry.getConsent()).toBe(ConsentState.Unknown)
	expect(getCheckbox().isChecked).toBe(false)
	expect(mockSentEvents).toEqual({})
end)

test("doesn't appear in embedded clients", function()
	renderRow(AppMode.EmbeddedClient)

	expect(getCheckbox()).toBeNil()
end)
