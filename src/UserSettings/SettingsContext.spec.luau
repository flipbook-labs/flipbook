local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ContextStack = require("@root/Common/ContextStack")
local MockPlugin = require("@root/Testing/MockPlugin")
local PluginContext = require("@root/Plugin/PluginContext")
local SettingsContext = require("./SettingsContext")
local defaultSettings = require("./defaultSettings")
local renderHook = require("@root/Testing/renderHook")

local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local test = JestGlobals.test

local act = ReactRoblox.act

local mockPlugin
local ContextWrapper

beforeEach(function()
	mockPlugin = MockPlugin.new()

	function ContextWrapper(props)
		return React.createElement(ContextStack, {
			providers = {
				React.createElement(PluginContext.Provider, {
					plugin = mockPlugin :: any,
				}),
				React.createElement(SettingsContext.Provider),
			},
		}, props.children)
	end

	jest.clearAllMocks()
end)

describe("hook", function()
	test("return default settings when no changes have been made", function()
		local get = renderHook(function()
			return SettingsContext.use()
		end, {
			wrapper = ContextWrapper,
		})

		local settingsContext = get()

		expect(settingsContext.settings).toEqual(defaultSettings)
	end)

	test("local plugin settings override defaults", function()
		mockPlugin:SetSetting("rememberLastOpenedStory", false)

		local get = renderHook(function()
			return SettingsContext.use()
		end, {
			wrapper = ContextWrapper,
		})

		local settingsContext = get()

		expect(settingsContext.settings.rememberLastOpenedStory.value).toBe(false)
	end)

	test.only("set setting value via context", function()
		local get = renderHook(function()
			return SettingsContext.use()
		end, {
			wrapper = ContextWrapper,
		})

		local settingsContext = get()

		expect(settingsContext.settings.rememberLastOpenedStory.value).toBe(true)

		act(function()
			settingsContext.setSetting("rememberLastOpenedStory", false)
		end)

		settingsContext = get()

		expect(settingsContext.settings.rememberLastOpenedStory.value).toBe(false)
	end)
end)
