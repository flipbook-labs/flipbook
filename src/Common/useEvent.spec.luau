local JestGlobals = require("@pkg/jest-globals")
local React = require("@pkg/react")
local ReactRoblox = require("@pkg/react-roblox")
local useEvent = require("./useEvent")

local afterEach = JestGlobals.afterEach
local expect = JestGlobals.expect
local test = JestGlobals.test

local container = Instance.new("ScreenGui")
local root = ReactRoblox.createRoot(container)

local bindable = Instance.new("BindableEvent")
local wasFired = false

local function HookTester()
	useEvent(bindable.Event, function()
		wasFired = true
	end)

	return nil
end

afterEach(function()
	wasFired = false

	ReactRoblox.act(function()
		root:unmount()
	end)
end)

test("listen to the given event", function()
	local element = React.createElement(HookTester)

	ReactRoblox.act(function()
		root:render(element)
	end)

	expect(wasFired).toBe(false)

	bindable:Fire()

	expect(wasFired).toBe(true)
end)

test("never fire when unmounted", function()
	local element = React.createElement(HookTester)

	ReactRoblox.act(function()
		root:render(element)
	end)

	expect(wasFired).toBe(false)

	ReactRoblox.act(function()
		root:unmount()
	end)

	bindable:Fire()

	expect(wasFired).toBe(false)
end)
