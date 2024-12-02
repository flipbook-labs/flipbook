local JestGlobals = require("@pkg/jest-globals")

local React = require("@pkg/react")
local ReactRoblox = require("@pkg/react-roblox")

local ContextProviders = require("@root/Common/ContextProviders")
local MockPlugin = require("@root/Testing/MockPlugin")
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
		return React.createElement(ContextProviders, {
			plugin = mockPlugin :: any,
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
		mockPlugin:SetSetting("sidebarWidth", 400)

		local get = renderHook(function()
			return SettingsContext.use()
		end, {
			wrapper = ContextWrapper,
		})

		local settingsContext = get()

		expect(settingsContext.settings.sidebarWidth.value).toBe(400)
	end)

	test("set setting value via context", function()
		local get = renderHook(function()
			return SettingsContext.use()
		end, {
			wrapper = ContextWrapper,
		})

		local settingsContext = get()

		expect(settingsContext.settings.sidebarWidth.value).toBe(260)

		act(function()
			settingsContext.setSetting("sidebarWidth", 400)
		end)

		settingsContext = get()

		expect(settingsContext.settings.sidebarWidth.value).toBe(400)
	end)
end)
