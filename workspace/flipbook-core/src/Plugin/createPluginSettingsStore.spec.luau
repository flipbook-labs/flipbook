local HttpService = game:GetService("HttpService")

local JestGlobals = require("@pkg/JestGlobals")
local t = require("@pkg/t")

local MockPlugin = require("@root/Testing/MockPlugin")

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test
local jest = JestGlobals.jest

local MOCK_STORAGE_KEY = "MockStorageKey"

local mockPlugin

local createPluginSettingsStore

beforeEach(function()
	mockPlugin = MockPlugin.new()

	jest.mock(script.Parent.PluginStore, function()
		return {
			get = function()
				return {
					getPlugin = function()
						return mockPlugin
					end,
				}
			end,
		}
	end)

	createPluginSettingsStore = require("./createPluginSettingsStore")
end)

afterEach(function()
	-- Take a beat to allow work to finish. Without this we get some test
	-- failures and output spam from tests ending too early.
	task.wait()
	task.wait()

	jest.resetAllMocks()
end)

test("loads until data is read from disk", function()
	mockPlugin:SetSetting(MOCK_STORAGE_KEY, nil)

	local pluginSettingsStore = createPluginSettingsStore(
		MOCK_STORAGE_KEY,
		{
			foo = true,
		},
		t.interface({
			foo = t.boolean,
		})
	)

	expect(pluginSettingsStore.getIsLoading(false)).toBe(true)

	pluginSettingsStore.waitForLoaded()

	expect(pluginSettingsStore.getIsLoading(false)).toBe(false)
end)

test("propagate error signal when failing to read from disk", function()
	mockPlugin:SetSetting(MOCK_STORAGE_KEY, "this is not json")

	local pluginSettingsStore = createPluginSettingsStore(
		MOCK_STORAGE_KEY,
		{
			foo = true,
		},
		t.interface({
			foo = t.boolean,
		})
	)

	repeat
		task.wait()
	until pluginSettingsStore.getErr(false) ~= nil

	expect(pluginSettingsStore.getErr(false)).toBeDefined()
end)

test("propagate error signal when schema validation fails", function()
	mockPlugin:SetSetting(
		MOCK_STORAGE_KEY,
		HttpService:JSONEncode({
			foo = "this should be a boolean",
		})
	)

	local pluginSettingsStore = createPluginSettingsStore(

		MOCK_STORAGE_KEY,
		{
			foo = true,
		},
		t.interface({
			foo = t.boolean,
		})
	)

	repeat
		task.wait()
	until pluginSettingsStore.getErr(false) ~= nil

	expect(pluginSettingsStore.getErr(false)).toBeDefined()
end)

test("automatically load data on disk", function()
	mockPlugin:SetSetting(
		MOCK_STORAGE_KEY,
		HttpService:JSONEncode({
			greeting = "Hello!",
		})
	)

	local pluginSettingsStore = createPluginSettingsStore(
		MOCK_STORAGE_KEY,
		{
			greeting = "Hi!",
		},
		t.interface({
			greeting = t.string,
		})
	)

	expect(pluginSettingsStore.getStorage(false)).toEqual({
		greeting = "Hi!",
	})

	pluginSettingsStore.waitForLoaded()

	expect(pluginSettingsStore.getStorage(false)).toEqual({
		greeting = "Hello!",
	})
end)

test("setting data writes to disk", function()
	local pluginSettingsStore = createPluginSettingsStore(
		MOCK_STORAGE_KEY,
		{
			farewell = "Bye!",
		},
		t.interface({
			farewell = t.string,
		})
	)

	local newStorage = {
		farewell = "Goodbye!",
	}

	pluginSettingsStore.waitForLoaded()

	expect(mockPlugin:GetSetting(MOCK_STORAGE_KEY)).toBeUndefined()

	pluginSettingsStore.setStorage(newStorage)

	expect(pluginSettingsStore.getStorage(false)).toEqual(newStorage)
	expect(mockPlugin:GetSetting(MOCK_STORAGE_KEY)).toEqual(HttpService:JSONEncode(newStorage))
end)

test("determine if a setting's value is the default", function()
	local pluginSettingsStore = createPluginSettingsStore(
		MOCK_STORAGE_KEY,
		{
			farewell = "Bye!",
		},
		t.interface({
			farewell = t.string,
		})
	)

	expect(pluginSettingsStore.isSettingDefault("farewell")).toBe(true)

	pluginSettingsStore.waitForLoaded()

	pluginSettingsStore.setStorage({
		farewell = "Goodbye!",
	})

	expect(pluginSettingsStore.isSettingDefault("farewell")).toBe(false)
end)
