local flipbook = script:FindFirstAncestor("flipbook")

local JestGlobals = require(flipbook.Packages.Dev.JestGlobals)
local React = require(flipbook.Packages.React)
local ReactRoblox = require(flipbook.Packages.ReactRoblox)
local useEvent = require(script.Parent.useEvent)

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

	expect(wasFired).to.equal(false)

	bindable:Fire()

	expect(wasFired).to.equal(true)
end)

test("never fire when unmounted", function()
	local element = React.createElement(HookTester)

	ReactRoblox.act(function()
		root:render(element)
	end)

	expect(wasFired).to.equal(false)

	ReactRoblox.act(function()
		root:unmount()
	end)

	bindable:Fire()

	expect(wasFired).to.equal(false)
end)
