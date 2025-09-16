local HttpService = game:GetService("HttpService")

local JestGlobals = require("@pkg/JestGlobals")

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

test("fails silently for malformed data", function()
	mockSettings[MOCK_STORAGE_KEY] = "this is not json"

	local pluginSettingsStore = createPluginSettingsStore(mockPlugin, MOCK_STORAGE_KEY)

	expect(pluginSettingsStore.get(false)).toEqual({})
end)

test("automatically load data on disk", function()
	mockSettings[MOCK_STORAGE_KEY] = HttpService:JSONEncode({
		greeting = "Hello!",
	})

	local pluginSettingsStore = createPluginSettingsStore(mockPlugin, MOCK_STORAGE_KEY)

	expect(pluginSettingsStore.get(false)).toEqual({})

	-- Loading data is async, so it will be propagated after a frame or so
	task.wait()
	task.wait()

	expect(pluginSettingsStore.get(false)).toEqual({
		greeting = "Hello!",
	})
end)

test("setting data writes to disk", function()
	local pluginSettingsStore = createPluginSettingsStore(mockPlugin, MOCK_STORAGE_KEY)

	local newStorage = {
		farewell = "Goodbye!",
	}

	print("set")
	pluginSettingsStore.set(newStorage)

	expect(pluginSettingsStore.get(false)).toEqual(newStorage)
	expect(mockSettings[MOCK_STORAGE_KEY]).toBeUndefined()

	-- Saving data is async, so it will be propagated after a frame or so
	task.wait()
	task.wait()

	print("check")
	expect(mockSettings[MOCK_STORAGE_KEY]).toEqual(HttpService:JSONEncode(newStorage))
end)
