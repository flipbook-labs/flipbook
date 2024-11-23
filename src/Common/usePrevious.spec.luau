local JestGlobals = require("@pkg/jest-globals")
local React = require("@pkg/react")
local ReactRoblox = require("@pkg/react-roblox")
local useEvent = require("@root/Common/useEvent")
local usePrevious = require("./usePrevious")

local expect = JestGlobals.expect
local test = JestGlobals.test
local afterEach = JestGlobals.afterEach

local container = Instance.new("ScreenGui")
local root = ReactRoblox.createRoot(container)

local toggleState = Instance.new("BindableEvent")

local function HookTester()
	local state, setState = React.useState(false)
	local prev = usePrevious(state)

	useEvent(toggleState.Event, function()
		setState(not state)
	end)

	return React.createElement("TextLabel", {
		Text = tostring(prev),
	})
end

afterEach(function()
	ReactRoblox.act(function()
		root:unmount()
	end)
end)

test("use the last value", function()
	local element = React.createElement(HookTester)

	ReactRoblox.act(function()
		root:render(element)
	end)

	local result = container:FindFirstChildWhichIsA("TextLabel") :: TextLabel

	expect(result.Text).toBe("nil")

	ReactRoblox.act(function()
		toggleState:Fire()
	end)

	ReactRoblox.act(function()
		task.wait()
	end)

	expect(result.Text).toBe("false")

	ReactRoblox.act(function()
		toggleState:Fire()
	end)

	ReactRoblox.act(function()
		task.wait()
	end)

	expect(result.Text).toBe("true")
end)
