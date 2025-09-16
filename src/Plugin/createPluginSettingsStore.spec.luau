local HttpService = game:GetService("HttpService")

local JestGlobals = require("@pkg/JestGlobals")
local t = require("@pkg/t")

local createPluginSettingsStore = require("./createPluginSettingsStore")

local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local test = JestGlobals.test
local jest = JestGlobals.jest

local MOCK_STORAGE_KEY = "MockStorageKey"

local mockSettings
local mockPlugin

beforeEach(function()
	mockSettings = {}

	mockPlugin = (
		{
			GetSetting = jest.fn(function(_self, key: string)
				task.wait() -- Simulate reading from disk
				return mockSettings[key]
			end),
			SetSetting = jest.fn(function(_self, key: string, value: any)
				task.wait() -- Simulate writing to disk
				mockSettings[key] = value
			end),
		} :: any
	) :: Plugin
end)

test("loads until data is read from disk", function()
	mockSettings[MOCK_STORAGE_KEY] = nil

	local pluginSettingsStore = createPluginSettingsStore(
		mockPlugin,
		MOCK_STORAGE_KEY,
		{
			foo = true,
		},
		t.interface({
			foo = t.boolean,
		})
	)

	expect(pluginSettingsStore.getIsLoading(false)).toBe(true)

	repeat
		task.wait()
	until pluginSettingsStore.getIsLoading(false) == false

	expect(pluginSettingsStore.getIsLoading(false)).toBe(false)
end)

test("propagate error signal when failing to read from disk", function()
	mockSettings[MOCK_STORAGE_KEY] = "this is not json"

	local pluginSettingsStore = createPluginSettingsStore(
		mockPlugin,
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
	mockSettings[MOCK_STORAGE_KEY] = HttpService:JSONEncode({
		foo = "this should be a boolean",
	})

	local pluginSettingsStore = createPluginSettingsStore(
		mockPlugin,
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
	mockSettings[MOCK_STORAGE_KEY] = HttpService:JSONEncode({
		greeting = "Hello!",
	})

	local pluginSettingsStore = createPluginSettingsStore(
		mockPlugin,
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

	-- Loading data is async, so it will be propagated after a frame or so
	task.wait()
	task.wait()

	expect(pluginSettingsStore.getStorage(false)).toEqual({
		greeting = "Hello!",
	})
end)

test("setting data writes to disk", function()
	local pluginSettingsStore = createPluginSettingsStore(
		mockPlugin,
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
	pluginSettingsStore.setStorage(newStorage)

	expect(pluginSettingsStore.getStorage(false)).toEqual(newStorage)
	expect(mockSettings[MOCK_STORAGE_KEY]).toBeUndefined()

	-- Saving data is async, so it will be propagated after a frame or so
	task.wait()
	task.wait()

	expect(mockSettings[MOCK_STORAGE_KEY]).toEqual(HttpService:JSONEncode(newStorage))
end)
