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

local SAVE_ERROR = "Flipbook couldn't save your choice. Try again."

-- Required in beforeEach, after requestAsync and Foundation are mocked.
local FlipbookStoreContext: typeof(require("@root/FlipbookStore/FlipbookStoreContext"))
local TelemetryConsentDialog: typeof(require("./TelemetryConsentDialog"))
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
	TelemetryConsentDialog = require("./TelemetryConsentDialog")
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

local function renderDialog(mode: AppMode?)
	local store = createFlipbookStore({
		mode = mode or AppMode.PluginWidget,
		plugin = plugin,
	})

	act(function()
		root:render(React.createElement(FlipbookStoreContext.Provider, {
			store = store,
		}, {
			Dialog = React.createElement(TelemetryConsentDialog),
		}))
	end)

	return store.telemetry
end

local function isDialogOpen(): boolean
	return #foundation.getMountedProps("Dialog.Root") > 0
end

local function isSaveErrorShown(): boolean
	for _, props in foundation.getMountedProps("Dialog.Text") do
		if props.Text == SAVE_ERROR then
			return true
		end
	end
	return false
end

local function setChecked(isChecked: boolean)
	act(function()
		foundation.getMountedProps("Checkbox")[1].onActivated(isChecked)
	end)
end

local function pressDone()
	act(function()
		foundation.getMountedProps("Dialog.Actions")[1].actions[1].onActivated()
	end)
end

local function dismiss()
	act(function()
		foundation.getMountedProps("Dialog.Root")[1].onClose()
	end)
end

test("asks with the box unchecked when no choice is saved", function()
	renderDialog()

	expect(isDialogOpen()).toBe(true)
	expect(foundation.getMountedProps("Checkbox")[1].isChecked).toBe(false)
end)

test("waits for consent to load before asking", function()
	local loading: thread?
	plugin.GetSetting = function()
		loading = coroutine.running()
		return coroutine.yield()
	end

	renderDialog()
	expect(isDialogOpen()).toBe(false)

	plugin.GetSetting = function()
		return nil
	end
	act(function()
		assert(loading, "consent did not start loading")
		task.spawn(loading, nil)
	end)
	expect(isDialogOpen()).toBe(true)
end)

test("shares usage data once the box is checked and Done is pressed", function()
	local telemetry = renderDialog()

	setChecked(true)
	expect(telemetry.getConsent()).toBe(ConsentState.Unknown)

	pressDone()
	expect(telemetry.getConsent()).toBe(ConsentState.Granted)
	expect(mockSentEvents).toEqual({ "TelemetryOptedIn" })
	expect(isDialogOpen()).toBe(false)
end)

test("declines when Done is pressed with the box unchecked", function()
	local telemetry = renderDialog()

	pressDone()

	expect(telemetry.getConsent()).toBe(ConsentState.Denied)
	expect(mockSentEvents).toEqual({})
	expect(isDialogOpen()).toBe(false)
end)

test("declines when dismissed with the box unchecked", function()
	local telemetry = renderDialog()

	dismiss()

	expect(telemetry.getConsent()).toBe(ConsentState.Denied)
	expect(mockSentEvents).toEqual({})
	expect(isDialogOpen()).toBe(false)
end)

test("doesn't ask again after a choice is saved", function()
	renderDialog()
	pressDone()
	act(function()
		root:unmount()
	end)

	root = ReactRoblox.createRoot(Instance.new("Folder"))
	local telemetry = renderDialog()

	expect(telemetry.getConsent()).toBe(ConsentState.Denied)
	expect(isDialogOpen()).toBe(false)
end)

test("doesn't ask in embedded clients", function()
	renderDialog(AppMode.EmbeddedClient)

	expect(isDialogOpen()).toBe(false)
end)

for _, isChecked in { true, false } do
	test(
		`stays open with an error when saving fails with the box {if isChecked then "checked" else "unchecked"}`,
		function()
			local telemetry = renderDialog()
			setChecked(isChecked)

			canSave = false
			pressDone()

			expect(isDialogOpen()).toBe(true)
			expect(isSaveErrorShown()).toBe(true)
			expect(telemetry.getConsent()).never.toBe(ConsentState.Granted)
			expect(mockSentEvents).toEqual({})

			canSave = true
			pressDone()

			expect(isDialogOpen()).toBe(false)
			expect(telemetry.getConsent()).toBe(if isChecked then ConsentState.Granted else ConsentState.Denied)
		end
	)
end
