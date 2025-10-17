local CoreGui = game:GetService("CoreGui")

local JestGlobals = require("@pkg/JestGlobals")
local React = require("@pkg/React")
local ReactRoblox = require("@pkg/ReactRoblox")

local ContextProviders = require("@root/Common/ContextProviders")
local PluginApp = require("./PluginApp")

local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local jest = JestGlobals.jest
local expect = JestGlobals.expect
local test = JestGlobals.test

local container
local mockSettings
local mockPlugin

beforeEach(function()
	container = Instance.new("Folder")
	container.Parent = CoreGui

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

afterEach(function()
	container:Destroy()
end)

test("app smoketest", function()
	local root = ReactRoblox.createRoot(container)
	local app = React.createElement(ContextProviders, {
		plugin = mockPlugin,
	}, {
		PluginApp = React.createElement(PluginApp),
	})

	expect(function()
		root:render(app)
	end).never.toThrow()
end)
